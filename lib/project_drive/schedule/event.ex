defmodule ProjectDrive.Schedule.Event do
  use ProjectDrive.Schema
  import Ecto.{Changeset, Query}

  alias ProjectDrive.Schedule.Event

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
    |> prepare_changes(fn changeset ->
      changeset
      |> validate_no_conflicts()
    end)
  end

  defp validate_no_conflicts(changeset) do
    id = get_field(changeset, :id)
    starts_at = get_field(changeset, :starts_at)
    ends_at = get_field(changeset, :ends_at)

    query =
      from ev in Event,
        where:
          ev.id != ^id and
            ^starts_at < ev.ends_at and
            ^ends_at > ev.starts_at,
        select: count(ev.id)

    conflicts = changeset.repo.one(query)

    if conflicts > 0 do
      changeset
      |> add_error(:starts_at, "The provided times conflict with existing events")
      |> add_error(:starts_at, "The provided times conflict with existing events")
    else
      changeset
    end
  end
end
