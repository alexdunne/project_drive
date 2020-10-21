defmodule ProjectDrive.Identity do
  @moduledoc """
  The Accounts context
  """
  import Ecto.Query, warn: false

  alias ProjectDrive.{Repo}
  alias ProjectDrive.Identity.{Credential, User}

  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Fetches a user with a matching email and password.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> login_with_email_and_password!("hi@alexdunne.net", "password")
      %User{}

      iex> login_with_email_and_password!("hi@alexdunne.net", "incorrect")
      ** (Ecto.NoResultsError)
  """
  def login_with_email_and_password!(email, password) do
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

  def create_new_user_changeset(%{email: email, password: password}) do
    user_attrs = %{credential: %{email: email, plain_password: password}}

    %User{}
    |> User.changeset(user_attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
  end
end
