defmodule ProjectDrive.Accounts do
  import Ecto.Query, warn: false

  alias ProjectDrive.{Repo, Mailer}
  alias ProjectDrive.Accounts.{Credential, Email, Instructor, Policy, StudentInvite, User}

  use EventBus.EventSource

  def get_user!(id), do: Repo.get!(User, id)

  def get_instructor_for_user!(user_id) do
    Repo.get_by!(Instructor, %{user_id: user_id})
  end

  def get_instructor!(id), do: Repo.get!(Instructor, id)

  def create_instructor(attrs) do
    user =
      %User{}
      |> User.changeset(attrs)
      |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
      |> Repo.insert!()

    %Instructor{user: user, email: attrs.email, name: attrs.name}
    |> Instructor.changeset(attrs)
    |> Repo.insert!()

    {:ok, user}
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
    user =
      Repo.get_by!(User, email: email)
      |> Repo.preload(:credential)

    password_matches = Argon2.verify_pass(password, user.credential.password)

    if password_matches do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end

  def create_student_invite(%Instructor{} = instructor, invite_attrs) do
    with :ok <- Bodyguard.permit!(Policy, :create_student_invite, instructor, invite_attrs) do
      {:ok, student_invite} =
        Ecto.build_assoc(instructor, :student_invites, %{email: invite_attrs.email})
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

  defp publish_event(%StudentInvite{} = student_invite, event_name) do
    EventSource.notify %{id: UUID.uuid4(), topic: event_name} do
      %{student_invite: student_invite}
    end
  end
end
