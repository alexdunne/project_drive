defmodule ProjectDriveWeb.Schema.AuthTypes do
  use Absinthe.Schema.Notation

  input_object :register_input do
    field :email, non_null(:string)
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
    field :email, :string
    field :name, :string
  end
end
