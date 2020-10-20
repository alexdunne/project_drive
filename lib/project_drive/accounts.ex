defmodule ProjectDrive.Accounts do
  @moduledoc """
  The Accounts context
  """
  import Ecto.Query, warn: false

  alias ProjectDrive.{Accounts, Identity, Mailer, Repo}
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

  def create_instructor(attrs) do
    {:ok, %{user: user}} =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:user, fn _, _ ->
        Identity.create_user(%{email: attrs.email, password: attrs.password})
      end)
      |> Ecto.Multi.run(:instructor, fn _repo, %{user: user} ->
        create_instructor_for_user(user, %{name: attrs.name, email: attrs.email})
      end)
      |> Repo.transaction()

    {:ok, user}
  end

  defp create_instructor_for_user(%Identity.User{} = user, attrs) do
    Ecto.build_assoc(user, :instructor)
    |> Instructor.changeset(attrs)
    |> Repo.insert()
  end

  def create_student(attrs) do
    with student_invite <- Repo.get_by!(StudentInvite, token: attrs.token),
         false <- StudentInvite.has_expired?(student_invite) do
      instructor = get_instructor(student_invite.instructor_id)
      student = get_student_by_email(instructor, student_invite.email)

      {:ok, %{user: user}} =
        Ecto.Multi.new()
        |> Ecto.Multi.run(:user, fn _, _ ->
          Identity.create_user(%{email: student_invite.email, password: attrs.password})
        end)
        |> Ecto.Multi.run(:student, fn repo, %{user: user} ->
          student
          |> Repo.preload(:user)
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.put_assoc(:user, user)
          |> repo.update()
        end)
        |> Ecto.Multi.update(:expire_student_invite, StudentInvite.expire_invite_changeset(student_invite))
        |> Ecto.Multi.run(:update_email_confirmation_state, fn repo, %{student: student} ->
          {:ok, updated_student} = Machinery.transition_to(student, StudentEmailConfirmationStateMachine, "confirmed")

          student
          |> Student.changeset(Map.from_struct(updated_student))
          |> repo.update()
        end)
        |> Repo.transaction()

      {:ok, user}
    end
  end

  def create_student_invite(%Instructor{} = instructor, invite_attrs) do
    with :ok <- Bodyguard.permit!(Accounts, :create_student_invite, instructor, invite_attrs) do
      {:ok, %{student_invite: student_invite, student: student}} =
        Ecto.Multi.new()
        |> Ecto.Multi.insert(:student_invite, build_student_invite_changeset(instructor, invite_attrs))
        |> Ecto.Multi.run(:student, fn repo, %{student_invite: student_invite} ->
          Ecto.build_assoc(instructor, :students)
          |> Student.changeset(%{name: student_invite.name, email: student_invite.email})
          |> repo.insert()
        end)
        |> Repo.transaction()

      publish_event(student_invite, :"accounts.student_invite.created")

      {:ok, student_invite, student}
    end
  end

  def send_student_invite_email(%StudentInvite{} = student_invite) do
    student_invite = Repo.preload(student_invite, :instructor)

    Email.student_invite_email(student_invite)
    |> Mailer.deliver_now()
  end

  defp build_student_invite_changeset(%Instructor{} = instructor, %{name: name, email: email}) do
    Ecto.build_assoc(instructor, :student_invites)
    |> StudentInvite.changeset(%{
      name: name,
      email: email,
      token: UUID.uuid4(),
      expires_at: Timex.shift(Timex.now(), hours: 48)
    })
  end

  defp publish_event(%StudentInvite{} = student_invite, event_name) do
    EventSource.notify %{id: UUID.uuid4(), topic: event_name} do
      %{student_invite: student_invite}
    end
  end
end
