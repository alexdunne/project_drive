defmodule ProjectDrive.Schedule.Policy do
  @moduledoc false

  @behaviour Bodyguard.Policy

  alias ProjectDrive.{Accounts, Schedule}

  def authorize(:view_event, %Accounts.Instructor{} = instructor, %Schedule.Event{} = event) do
    instructor.id == event.instructor_id
  end

  def authorize(:create_lesson, %Accounts.Instructor{} = instructor, %Accounts.Student{} = student) do
    instructor.id == student.instructor_id
  end

  def authorize(:update_lesson, %Accounts.Instructor{} = instructor, %Schedule.Event{} = event) do
    instructor.id == event.instructor_id
  end

  def authorize(:delete_lesson, %Accounts.Instructor{} = instructor, %Schedule.Event{} = event) do
    instructor.id == event.instructor_id
  end

  def authorize(_, _, _), do: false
end
