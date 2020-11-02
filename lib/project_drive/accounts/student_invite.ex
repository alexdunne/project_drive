defmodule ProjectDrive.Accounts.StudentInvite do
  @moduledoc false

  use ProjectDrive.Schema
  import Ecto.Changeset

  alias ProjectDrive.Accounts.{Instructor, StudentInvite}

  require Logger

  schema "student_invites" do
    field :name, :string
    field :email, :string
    field :token, :string
    field :expires_at, :utc_datetime

    belongs_to :instructor, Instructor

    timestamps()
  end

  @doc false
  def changeset(student_invite, attrs) do
    student_invite
    |> cast(attrs, [:name, :email, :token, :expires_at])
    |> validate_required([:name, :email, :token, :expires_at])
    |> validate_is_future_date(:expires_at)
    |> unique_constraint([:email, :instructor_id])
  end

  defp validate_is_future_date(changeset, field) do
    date_to_check = get_field(changeset, field)

    case Timex.compare(Timex.now(), date_to_check) do
      -1 ->
        changeset

      _ ->
        add_error(changeset, field, "must be in the future")
    end
  end
end
