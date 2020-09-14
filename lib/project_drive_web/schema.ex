defmodule ProjectDriveWeb.Schema do
  use Absinthe.Schema
  import_types(ProjectDriveWeb.Schema.AuthTypes)

  alias ProjectDriveWeb.Resolvers

  query do
  end

  mutation do
    @desc "Register a new user account"
    field :register, :auth_payload do
      arg(:input, non_null(:register_input))

      resolve(&Resolvers.Auth.register/3)
    end
  end
end
