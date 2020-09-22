defmodule ProjectDrive.Schedule.Instructor do
  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.{Schedule, Identity}

  schema "instructors" do
    field :email, :string
    field :name, :string

    belongs_to :user, Identity.User
    has_many :student_invites, Schedule.StudentInvite
    has_many :students, Schedule.Student

    timestamps()
  end

  @doc false
  def changeset(instructor, attrs) do
    instructor
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
  end
end
