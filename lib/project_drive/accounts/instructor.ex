defmodule ProjectDrive.Accounts.Instructor do
  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.Accounts.{StudentInvite, User}

  schema "instructors" do
    field :email, :string
    field :name, :string

    belongs_to :user, User
    has_many :student_invites, StudentInvite

    timestamps()
  end

  @doc false
  def changeset(instructor, attrs) do
    instructor
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
  end
end
