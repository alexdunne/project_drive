defmodule ProjectDrive.Accounts.Student do
  @moduledoc """
  Represents a Student
  """

  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.{Accounts, Identity}

  schema "students" do
    field :email, :string
    field :name, :string

    # Holds the current state of invite process
    field :email_confirmation_state, :string, default: "awaiting_confirmation"

    belongs_to :user, Identity.User
    belongs_to :instructor, Accounts.Instructor

    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:email, :name, :email_confirmation_state])
    |> validate_required([:email, :name])
  end
end
