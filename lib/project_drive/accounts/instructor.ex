defmodule ProjectDrive.Accounts.Instructor do
  @moduledoc false

  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.{Accounts, Identity}

  schema "instructors" do
    field :email, :string
    field :name, :string

    belongs_to :user, Identity.User
    has_many :student_invites, Accounts.StudentInvite
    has_many :students, Accounts.Student

    timestamps()
  end

  @doc false
  def changeset(instructor, attrs) do
    instructor
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
  end
end
