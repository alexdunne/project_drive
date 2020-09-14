defmodule ProjectDrive.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ProjectDrive.Repo

  alias ProjectDrive.Accounts.{Credential, User}

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
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
end
