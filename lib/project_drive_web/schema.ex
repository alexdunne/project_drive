defmodule ProjectDriveWeb.Schema do
  use Absinthe.Schema
  import_types(ProjectDriveWeb.Schema.AuthTypes)

  alias ProjectDriveWeb.Resolvers

  query do
    field :test, :string do
      resolve(fn _, _ ->
        {:ok, "hi"}
      end)
    end
  end

  mutation do
    @desc "Register a new user account"
    field :register, :auth_payload do
      arg(:input, non_null(:register_input))

      resolve(&Resolvers.Auth.register/3)
    end

    @desc "Login with existing account credentials"
    field :login, :auth_payload do
      arg(:input, non_null(:login_input))

      resolve(&Resolvers.Auth.login/3)
    end
  end
end
