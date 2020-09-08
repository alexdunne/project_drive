defmodule ProjectDrive.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  alias ProjectDrive.Accounts.{Encryption, User}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "credentials" do
    field :email, :string
    field :password, :string
    field: :email_confirmed, :boolean

    field :plain_password, :string, virtual: true

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password])
    |> validate_required([:email])
    |> validate_length(:password, min: 6)
    |> validate_format(:email, ~r/^.+@.+$/i)
    |> unique_constraint(:email)
  end
end
