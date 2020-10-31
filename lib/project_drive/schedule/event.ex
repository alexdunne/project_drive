defmodule ProjectDrive.Schedule.Event do
  @moduledoc false

  use ProjectDrive.Schema
  import Ecto.{Changeset, Query}

  alias ProjectDrive.Accounts

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
    |> validate_required([:starts_at, :ends_at, :type, :instructor_id, :student_id])
    |> foreign_key_constraint(:student_id)
    |> set_seconds_to_zero(:starts_at)
    |> set_seconds_to_zero(:ends_at)
    |> validate_is_future_event()
    |> validate_is_before(:starts_at, :ends_at)
    |> prepare_changes(fn changeset ->
      changeset
      |> validate_no_conflicts()
    end)
  end

  defp validate_is_future_event(changeset) do
    starts_at = get_field(changeset, :starts_at)

    case Timex.compare(Timex.now(), starts_at) do
      -1 ->
        changeset

      _ ->
        add_error(changeset, :starts_at, "must be in the future")
    end
  end

  defp validate_is_before(changeset, first_date_field, second_date_field) do
    first_date = get_field(changeset, first_date_field)
    second_date = get_field(changeset, second_date_field)

    case Timex.compare(first_date, second_date) do
      -1 ->
        changeset

      _ ->
        add_error(changeset, first_date_field, "must be before the end time")
    end
  end

  defp validate_no_conflicts(changeset) do
    id = get_field(changeset, :id)
    instructor_id = get_field(changeset, :instructor_id)
    starts_at = get_field(changeset, :starts_at)
    ends_at = get_field(changeset, :ends_at)

    query =
      filter_by_instructor(instructor_id)
      |> select_conflicts_count(%{id: id, starts_at: starts_at, ends_at: ends_at})

    conflicts = changeset.repo.one(query)

    if conflicts > 0 do
      changeset
      |> add_error(:starts_at, "conflicts with existing events")
      |> add_error(:ends_at, "conflicts with existing events")
    else
      changeset
    end
  end

  defp set_seconds_to_zero(changeset, field) do
    field_value = get_field(changeset, field)

    put_change(changeset, field, Timex.set(field_value, second: 0))
  end

  def select_conflicts_count(query \\ __MODULE__, args)

  def select_conflicts_count(query, %{id: id, starts_at: starts_at, ends_at: ends_at}) do
    filter_by_id =
      if is_nil(id) do
        true
      else
        dynamic([ev], ev.id != ^id)
      end

    query
    |> where(^filter_by_id)
    |> where([ev], ^starts_at < ev.ends_at and ^ends_at > ev.starts_at)
    |> select([ev], count(ev.id))
  end

  def select_conflicts_count(query, %{starts_at: _starts_at, ends_at: _ends_at} = args) do
    args = Map.put(args, :id, nil)

    select_conflicts_count(query, args)
  end

  def filter_by_instructor(query \\ __MODULE__, instructor)

  def filter_by_instructor(query, %Accounts.Instructor{} = instructor) do
    from ev in query, where: ev.instructor_id == ^instructor.id
  end

  def filter_by_instructor(query, instructor_id) when is_binary(instructor_id) do
    from ev in query, where: ev.instructor_id == ^instructor_id
  end

  def order_events_asc(query) do
    from ev in query, order_by: [asc: :starts_at]
  end

  def filter(query, filters) do
    defaults = %{search_term: ""}
    filters = Map.merge(defaults, filters)

    search_term = String.downcase(filters[:search_term])

    query
    |> join(:inner, [ev], s in Accounts.Student, on: ev.student_id == s.id, as: :student)
    |> where(^filter_by_search_term(search_term))
  end

  defp filter_by_search_term("today") do
    today = Timex.now()

    filter_between_dates(today)
  end

  defp filter_by_search_term("tomorrow") do
    tomorrow = Timex.now() |> Timex.shift(days: 1)

    filter_between_dates(tomorrow)
  end

  defp filter_by_search_term("this week") do
    today = Timex.now()

    start_date = Timex.beginning_of_week(today)
    end_date = Timex.end_of_week(today)

    filter_between_dates(start_date, end_date)
  end

  defp filter_by_search_term("next week") do
    today = Timex.now() |> Timex.shift(weeks: 1)

    start_date = Timex.beginning_of_week(today)
    end_date = Timex.end_of_week(today)

    filter_between_dates(start_date, end_date)
  end

  defp filter_by_search_term(student_name) do
    value = String.trim(student_name)

    if String.length(value) > 0 do
      dynamic([student: s], ilike(s.name, ^"#{value}%"))
    else
      true
    end
  end

  defp filter_between_dates(date) do
    filter_between_dates(Timex.beginning_of_day(date), Timex.end_of_day(date))
  end

  defp filter_between_dates(start_date, end_date) do
    dynamic([ev], ev.starts_at >= ^start_date and ev.starts_at <= ^end_date)
  end
end
