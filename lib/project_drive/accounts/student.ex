defmodule ProjectDrive.Accounts.Student do
  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.{Accounts, Identity}

  schema "students" do
    field :email, :string
    field :name, :string

    belongs_to :user, Identity.User
    belongs_to :instructor, Accounts.Instructor

    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
  end
end
