defmodule ProjectDrive.Accounts.User do
  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.Accounts.{Credential, Instructor, Student}

  schema "users" do
    has_one :credential, Credential
    has_one :instructor, Instructor
    has_many :students, Student

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
