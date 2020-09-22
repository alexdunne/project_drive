defmodule ProjectDrive.Schedule.Event do
  use ProjectDrive.Schema
  import Ecto.Changeset

  schema "events" do
    field :ends_at, :utc_datetime
    field :starts_at, :utc_datetime
    field :notes, :string
    field :type, EventTypeEnum
    field :instructor_id, :binary_id
    field :student_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:starts_at, :ends_at, :notes, :type, :instructor_id, :student_id])
    |> validate_required([:starts_at, :ends_at, :notes, :type, :instructor_id, :student_id])
    |> foreign_key_constraint(:student_id)
  end
end
