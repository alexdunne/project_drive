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

  def get_students(%Instructor{} = instructor, ids) do
    Student
    |> Student.filter_by_instructor(instructor)
    |> where([s], s.id in ^ids)
    |> Repo.all()
  end

  def get_student_by_email(%Instructor{} = instructor, email) do
    Repo.one(from s in Student, where: s.email == ^email, where: s.instructor_id == ^instructor.id)
  end

  def get_student_invite(id), do: Repo.get(StudentInvite, id)

  def get_student_invite_by_token(token) do
    now = Timex.now()

    query =
      from si in StudentInvite,
        where: si.token == ^token and si.expires_at > ^now

    invite = Repo.one(query)

    {:ok, invite}
  end

  def list_students_query(%Instructor{} = instructor, opts \\ []) do
    Student
    |> Student.filter_by_instructor(instructor)
    |> Student.filter(opts[:filters])
    |> Student.order_students_asc()
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, opts[:filters])
  end

  def ensure_instructor_exists(%Identity.User{} = user) do
    %Instructor{user_id: user.id}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.unique_constraint(:user_id)
    |> Repo.insert()
    |> handle_existing_instructor()
  end

  defp handle_existing_instructor({:ok, instructor}), do: instructor

  defp handle_existing_instructor({:error, changeset}) do
    Repo.get_by!(Instructor, user_id: changeset.data.user_id)
  end

  def expire_student_invite(%StudentInvite{} = invite) do
    invite
    |> StudentInvite.changeset(%{expires_at: Timex.shift(Timex.now(), seconds: 1)})
    |> Repo.update()
  end

  def mark_student_email_as_confirmed(%Student{} = student) do
    {:ok, updated_student} = Machinery.transition_to(student, StudentEmailConfirmationStateMachine, "confirmed")

    student
    |> Student.changeset(Map.from_struct(updated_student))
    |> Repo.update()
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
