defmodule ProjectDrive.Accounts.User do
  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.Accounts.Credential

  schema "users" do
    field :email, :string
    field :name, :string

    has_one :credential, Credential

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
  end
end
