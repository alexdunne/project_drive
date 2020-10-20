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
    |> set_seconds_to_zero(:starts_at)
    |> set_seconds_to_zero(:ends_at)
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
        where: ^starts_at < ev.ends_at and ^ends_at > ev.starts_at,
        select: count(ev.id)

    query =
      if is_nil(id) do
        query
      else
        from ev in query, where: ev.id != ^id
      end

    conflicts = changeset.repo.one(query)

    if conflicts > 0 do
      changeset
      |> add_error(:starts_at, "The provided times conflict with existing events")
      |> add_error(:starts_at, "The provided times conflict with existing events")
    else
      changeset
    end
  end

  defp set_seconds_to_zero(changeset, field) do
    field_value = get_field(changeset, field)

    put_change(changeset, field, Timex.set(field_value, second: 0))
  end
end
