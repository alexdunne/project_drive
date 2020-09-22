defmodule ProjectDrive.Identity.Credential do
  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.Identity

  schema "credentials" do
    field :email, :string
    field :password, :string
    field :plain_password, :string, virtual: true

    belongs_to :user, Identity.User

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :plain_password])
    |> validate_required([:email, :plain_password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5, max: 20)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{plain_password: password}} = changeset) do
    put_change(changeset, :password, Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
