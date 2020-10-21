defmodule ProjectDriveWeb.Resolvers.Auth do
  @moduledoc """
  Resolvers for auth schema types
  """

  alias ProjectDrive.{Accounts, Guardian, Identity}

  def register(_parent, %{input: input}, _context) do
    case Accounts.create_instructor(%{name: input.name, email: input.email, password: input.password}) do
      {:ok, user} ->
        {:ok, jwt, _} = Guardian.encode_and_sign(user)
        {:ok, %{token: jwt, user: %{id: user.id}}}

      other ->
        other
    end
  end

  def register_student_invite(_parent, %{input: input}, _context) do
    case Accounts.create_student(%{name: input.name, token: input.token, password: input.password}) do
      {:ok, user} ->
        {:ok, jwt, _} = Guardian.encode_and_sign(user)
        {:ok, %{token: jwt, user: %{id: user.id}}}

      other ->
        other
    end
  end

  def login(_parent, %{input: input}, _context) do
    with {:ok, user} <- Identity.login_with_email_and_password!(input.email, input.password),
         {:ok, jwt, _} <- Guardian.encode_and_sign(user) do
      {:ok, %{token: jwt, user: %{id: user.id}}}
    else
      _ -> {:error, "Invalid credentials"}
    end
  end
end
