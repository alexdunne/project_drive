defmodule ProjectDriveWeb.Resolvers.Auth do
  alias ProjectDrive.Accounts

  def register(_parent, %{input: input}, _resolution) do
    {:ok, user} =
      Accounts.create_user(%{
        name: input.name,
        email: input.email,
        credential: %{
          email: input.email,
          plain_password: input.password
        }
      })

    {:ok, %{token: "abc", user: %{id: user.id, email: user.email, name: user.name}}}
  end
end
