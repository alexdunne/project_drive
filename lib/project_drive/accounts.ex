defmodule ProjectDrive.Accounts do
  @moduledoc """
  The Accounts context
  """
  import Ecto.Query, warn: false

  alias ProjectDrive.{Accounts, Repo, Mailer}

  alias ProjectDrive.Accounts.{
    Credential,
    Email,
    Instructor,
    Policy,
    Student,
    StudentInvite,
    User
  }

  require Logger

  use EventBus.EventSource

  defdelegate authorize(action, user, params), to: Policy

  def get_user!(id), do: Repo.get!(User, id)

  def get_instructor_for_user!(user_id) do
    Repo.get_by!(Instructor, %{user_id: user_id})
  end

  def get_instructor(id), do: Repo.get(Instructor, id)

  def get_student(id), do: Repo.get(Student, id)

  def create_instructor(attrs) do
    user_attrs = %{credential: %{email: attrs.email, plain_password: attrs.password}}
    instructor_attrs = %{name: attrs.name, email: attrs.email}

    create_user_changeset =
      %User{}
      |> User.changeset(user_attrs)
      |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)

    {:ok, %{user: user}} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:user, create_user_changeset)
      |> Ecto.Multi.run(:instructor, fn repo, %{user: user} ->
        Ecto.build_assoc(user, :instructor)
        |> Instructor.changeset(instructor_attrs)
        |> repo.insert()
      end)
      |> Repo.transaction()

    {:ok, user}
  end

  def create_student(attrs) do
    with student_invite <- Repo.get_by!(StudentInvite, token: attrs.token),
         false <- has_student_invite_expired(student_invite) do
      user_attrs = %{credential: %{email: student_invite.email, plain_password: attrs.password}}
      student_attrs = %{name: attrs.name, email: student_invite.email}

      student_invite =
        student_invite
        |> Repo.preload(:instructor)

      create_user_changeset =
        %User{}
        |> User.changeset(user_attrs)
        |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)

      expire_student_invite_changeset =
        student_invite
        |> StudentInvite.changeset(%{expires_at: Timex.shift(Timex.now(), seconds: 1)})

      {:ok, %{user: user}} =
        Ecto.Multi.new()
        |> Ecto.Multi.insert(:user, create_user_changeset)
        |> Ecto.Multi.run(:student, fn repo, %{user: user} ->
          Ecto.build_assoc(user, :students, %{instructor: student_invite.instructor})
          |> Student.changeset(student_attrs)
          |> repo.insert()
        end)
        |> Ecto.Multi.update(:student_invite, expire_student_invite_changeset)
        |> Repo.transaction()

      {:ok, user}
    end
  end

  @doc """
  Fetches a user with a matching email and password.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> login_with_email_and_password!("hi@alexdunne.net", "password")
      %User{}

      iex> login_with_email_and_password!("hi@alexdunne.net", "incorrect")
      ** (Ecto.NoResultsError)
  """
  def login_with_email_and_password(email, password) do
    credential =
      Repo.get_by!(Credential, email: email)
      |> Repo.preload(:user)

    password_matches = Argon2.verify_pass(password, credential.password)

    if password_matches do
      {:ok, credential.user}
    else
      {:error, :not_found}
    end
  end

  def create_student_invite(%Instructor{} = instructor, invite_attrs) do
    with :ok <- Bodyguard.permit!(Accounts, :create_student_invite, instructor, invite_attrs) do
      student_invites_attrs = build_student_invite_attrs(%{email: invite_attrs.email})

      {:ok, student_invite} =
        Ecto.build_assoc(instructor, :student_invites)
        |> StudentInvite.changeset(student_invites_attrs)
        |> Repo.insert()

      publish_event(student_invite, :"accounts.student_invite.created")

      {:ok, student_invite}
    end
  end

  def send_student_invite_email(%StudentInvite{} = student_invite) do
    student_invite =
      student_invite
      |> Repo.preload(:instructor)

    Email.student_invite_email(student_invite)
    |> Mailer.deliver_now()
  end

  defp build_student_invite_attrs(%{email: email}) do
    %{
      email: email,
      token: UUID.uuid4(),
      expires_at: Timex.shift(Timex.now(), hours: 48)
    }
  end

  defp has_student_invite_expired(%StudentInvite{} = student_invite) do
    formatted_now = Timex.format!(Timex.now(), "{RFC3339}")
    formatted_expires_at = Timex.format!(student_invite.expires_at, "{RFC3339}")

    Logger.info("Student invite expired check. Now: #{formatted_now}, Expires: #{formatted_expires_at}")

    case Timex.compare(Timex.today(), student_invite.expires_at) do
      -1 -> false
      _ -> true
    end
  end

  defp publish_event(%StudentInvite{} = student_invite, event_name) do
    EventSource.notify %{id: UUID.uuid4(), topic: event_name} do
      %{student_invite: student_invite}
    end
  end
end
