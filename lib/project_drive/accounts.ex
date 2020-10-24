defmodule ProjectDrive.Accounts do
  @moduledoc """
  The Accounts context
  """
  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias ProjectDrive.{Identity, Mailer, Repo}
  alias ProjectDrive.Accounts.{Email, Instructor, Policy, Student, StudentInvite, StudentEmailConfirmationStateMachine}

  require Logger

  use EventBus.EventSource

  defdelegate authorize(action, user, params), to: Policy

  def get_instructor_for_user!(user_id) do
    Repo.get_by!(Instructor, %{user_id: user_id})
  end

  def get_instructor(id), do: Repo.get(Instructor, id)

  def get_student(id), do: Repo.get(Student, id)

  def get_student_by_email(%Instructor{} = instructor, email) do
    Repo.one(from s in Student, where: s.email == ^email, where: s.instructor_id == ^instructor.id)
  end

  def get_student_invite(id), do: Repo.get(StudentInvite, id)

  def get_student_invite_by_token(token) do
    now = Timex.now()

    query =
      from si in StudentInvite,
        where: si.token == ^token and si.expires_at > ^now

    Repo.one(query)
  end

  def create_instructor(attrs) do
    Multi.new()
    |> Multi.insert(:user, Identity.create_new_user_changeset(attrs))
    |> Multi.run(:instructor, fn repo, %{user: user} ->
      build_new_instructor_changeset(user, attrs)
      |> repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _operation, changeset, _changes} -> {:error, changeset}
      other -> other
    end
  end

  def create_student(attrs) do
    case get_student_invite_by_token(attrs.token) do
      nil ->
        {:error, :not_found}

      student_invite ->
        instructor = get_instructor(student_invite.instructor_id)
        student = get_student_by_email(instructor, student_invite.email)

        Multi.new()
        |> Multi.insert(
          :user,
          Identity.create_new_user_changeset(%{
            email: student_invite.email,
            password: attrs.password
          })
        )
        |> Multi.run(:student, fn repo, %{user: user} ->
          student
          |> Repo.preload(:user)
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.put_assoc(:user, user)
          |> repo.update()
        end)
        |> Multi.update(:expire_student_invite, StudentInvite.expire_invite_changeset(student_invite))
        |> Multi.run(:update_email_confirmation_state, fn repo, %{student: student} ->
          {:ok, updated_student} = Machinery.transition_to(student, StudentEmailConfirmationStateMachine, "confirmed")

          student
          |> Student.changeset(Map.from_struct(updated_student))
          |> repo.update()
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{user: user}} -> {:ok, user}
          {:error, _operation, changeset, _changes} -> {:error, changeset}
          other -> other
        end
    end
  end

  def create_student_invite(%Instructor{} = instructor, invite_attrs) do
    Multi.new()
    |> Multi.insert(:student_invite, build_student_invite_changeset(instructor, invite_attrs))
    |> Multi.run(:student, fn repo, %{student_invite: student_invite} ->
      Ecto.build_assoc(instructor, :students)
      |> Student.changeset(%{name: student_invite.name, email: student_invite.email})
      |> repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{student_invite: student_invite, student: student}} ->
        publish_event(student_invite, :"accounts.student_invite.created")
        {:ok, student_invite, student}

      {:error, _operation, changeset, _changes} ->
        {:error, changeset}

      other ->
        other
    end
  end

  def send_student_invite_email(%StudentInvite{} = student_invite) do
    student_invite = Repo.preload(student_invite, :instructor)

    Email.student_invite_email(student_invite)
    |> Mailer.deliver_now()
  end

  defp build_new_instructor_changeset(%Identity.User{} = user, attrs) do
    Ecto.build_assoc(user, :instructor)
    |> Instructor.changeset(attrs)
  end

  defp build_student_invite_changeset(%Instructor{} = instructor, attrs) do
    invite_attrs =
      attrs
      |> Map.put(:token, UUID.uuid4())
      |> Map.put(:expires_at, Timex.shift(Timex.now(), hours: 48))

    Ecto.build_assoc(instructor, :student_invites)
    |> StudentInvite.changeset(invite_attrs)
  end

  defp publish_event(%StudentInvite{} = student_invite, event_name) do
    EventSource.notify %{id: UUID.uuid4(), topic: event_name} do
      %{student_invite: student_invite}
    end
  end
end
