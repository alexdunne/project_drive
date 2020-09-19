defmodule ProjectDrive.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ProjectDrive.Repo

  alias ProjectDrive.Accounts.{Credential, Instructor, Policy, User}

  def get_user!(id), do: Repo.get!(User, id)

  def get_instructor!(user_id) do
    Repo.get_by!(Instructor, %{user_id: user_id})
  end

  def create_instructor(attrs \\ %{}) do
    user =
      %User{}
      |> User.changeset(attrs)
      |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
      |> Repo.insert!()

    %Instructor{user: user}
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
      Ecto.build_assoc(instructor, :student_invites, %{email: invite_attrs.email})
      |> Repo.insert()
    end
  end
end
