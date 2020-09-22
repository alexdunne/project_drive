defmodule ProjectDrive.Schedule do
  @moduledoc """
  The Schedule context.
  """

  import Ecto.Query, warn: false

  alias ProjectDrive.{Repo, Schedule}
  alias ProjectDrive.Schedule.{Event, Instructor, Policy, Student}

  defdelegate authorize(action, user, params), to: Policy

  def create_lesson(%Instructor{} = instructor, event_attrs) do
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

  def instructor_for_instructor_account(%ProjectDrive.Accounts.Instructor{} = instructor_account) do
    %Instructor{id: instructor_account.id}
  end

  def student_for_student_account(%ProjectDrive.Accounts.Student{} = student_account) do
    %Student{
      id: student_account.id,
      name: student_account.name,
      email: student_account.email,
      instructor_id: student_account.instructor_id
    }
  end
end
