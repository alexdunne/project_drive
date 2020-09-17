defmodule ProjectDrive.Accounts.Instructor do
  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.Accounts.User

  schema "instructors" do
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(instructor, attrs) do
    instructor
    |> cast(attrs, [])
    |> validate_required([])
  end
end
