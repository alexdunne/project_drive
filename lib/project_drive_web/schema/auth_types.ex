defmodule ProjectDriveWeb.Schema.AuthTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ProjectDriveWeb.{Resolvers}

  object :user do
    field :id, non_null(:id)
  end

  object :auth_mutations do
    @desc "Register a new user account"
    payload field :register do
      input do
        field :email, non_null(:string)
        field :password, non_null(:string)
        field :name, non_null(:string)
      end

      output do
        field :token, non_null(:string)
        field :user, :user
      end

      resolve(&Resolvers.Auth.register/3)
    end

    @desc "Register a new user account from a student invite"
    payload field :register_from_student_invite do
      input do
        field :token, non_null(:string)
        field :password, non_null(:string)
        field :name, non_null(:string)
      end

      output do
        field :token, non_null(:string)
        field :user, :user
      end

      resolve(&Resolvers.Auth.register_student_invite/3)
    end

    @desc "Login with existing account credentials"
    payload field :login do
      input do
        field :email, non_null(:string)
        field :password, non_null(:string)
      end

      output do
        field :token, non_null(:string)
        field :user, :user
      end

      resolve(&Resolvers.Auth.login/3)
    end
  end
end
