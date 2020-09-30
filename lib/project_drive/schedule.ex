defmodule ProjectDrive.Schedule do
  @moduledoc """
  The Schedule context.
  """

  import Ecto.Query, warn: false

  alias ProjectDrive.{Accounts, Repo, Schedule}
  alias ProjectDrive.Schedule.{Event, Policy}

  defdelegate authorize(action, user, params), to: Policy

  def get_event(id), do: Repo.get(Event, id)

  def create_lesson(%Accounts.Instructor{} = instructor, lesson_attrs) do
    with :ok <- Bodyguard.permit!(Schedule, :create_lesson, instructor, lesson_attrs) do
      attrs =
        lesson_attrs
        |> Map.put(:instructor_id, instructor.id)
        |> Map.put(:type, :lesson)

      %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert()
    end
  end

  def update_lesson(%Accounts.Instructor{} = instructor, %{id: event_id} = lesson_attrs) do
    event = get_event(event_id)

    with :ok <- Bodyguard.permit!(Schedule, :update_lesson, instructor, event) do
      event
      |> Event.changeset(lesson_attrs)
      |> Repo.update()
    end
  end
end
