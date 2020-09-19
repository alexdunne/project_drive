defmodule ProjectDrive.Accounts.StudentInvite do
  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.Accounts.Instructor

  schema "student_invites" do
    field :email, :string
    belongs_to :instructor, Instructor

    timestamps()
  end

  @doc false
  def changeset(student_invite, attrs) do
    student_invite
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint([:email, :instructor_id])
  end
end
