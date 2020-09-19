defmodule ProjectDriveWeb.Schema.AuthTypes do
  use Absinthe.Schema.Notation

  alias ProjectDriveWeb.{Resolvers}

  input_object :register_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :name, non_null(:string)
  end

  input_object :register_student_invite_input do
    field :token, non_null(:string)
    field :password, non_null(:string)
    field :name, non_null(:string)
  end

  input_object :login_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
  end

  object :auth_payload do
    field :token, :string
    field :user, :user
  end

  object :user do
    field :id, :id
  end

  object :auth_mutations do
    @desc "Register a new user account"
    field :register, :auth_payload do
      arg(:input, non_null(:register_input))

      resolve(&Resolvers.Auth.register/3)
    end

    @desc "Register a new user account from a student invite"
    field :register_from_student_invite, :auth_payload do
      arg(:input, non_null(:register_student_invite_input))

      resolve(&Resolvers.Auth.register_student_invite/3)
    end

    @desc "Login with existing account credentials"
    field :login, :auth_payload do
      arg(:input, non_null(:login_input))

      resolve(&Resolvers.Auth.login/3)
    end
  end
end
