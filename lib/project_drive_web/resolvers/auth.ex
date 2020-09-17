defmodule ProjectDriveWeb.Resolvers.Auth do
  alias ProjectDrive.Accounts

  def register(_parent, %{input: input}, _context) do
    {:ok, user} =
      Accounts.create_instructor(%{
        name: input.name,
        email: input.email,
        credential: %{
          email: input.email,
          plain_password: input.password
        }
      })

    {:ok, jwt, _} = ProjectDrive.Guardian.encode_and_sign(user)

    {:ok,
     %{
       token: jwt,
       user: %{
         id: user.id,
         email: user.email,
         name: user.name
       }
     }}
  end

  def login(_parent, %{input: input}, _context) do
    with {:ok, user} <- Accounts.login_with_email_and_password(input.email, input.password),
         {:ok, jwt, _} <- ProjectDrive.Guardian.encode_and_sign(user) do
      {:ok,
       %{
         token: jwt,
         user: %{
           id: user.id,
           email: user.email,
           name: user.name
         }
       }}
    end
  end
end
