defmodule ProjectDrive.Schedule do
  @moduledoc """
  The Schedule context.
  """

  import Ecto.Query, warn: false

  alias ProjectDrive.{Accounts, Repo, Schedule}
  alias ProjectDrive.Schedule.{Event, Policy}

  defdelegate authorize(action, user, params), to: Policy

  def create_lesson(%Accounts.Instructor{} = instructor, event_attrs) do
    with :ok <- Bodyguard.permit!(Schedule, :create_lesson, instructor, event_attrs) do
      attrs =
        event_attrs
        |> Map.put(:instructor_id, instructor.id)
        |> Map.put(:type, :lesson)

      %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert!()
    end
  end
end
