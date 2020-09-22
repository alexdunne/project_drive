defmodule ProjectDrive.Identity.User do
  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.{Accounts, Identity}

  schema "users" do
    has_one :credential, Identity.Credential
    has_one :instructor, Accounts.Instructor
    has_many :students, Accounts.Student

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
