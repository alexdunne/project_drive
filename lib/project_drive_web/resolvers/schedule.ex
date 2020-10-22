defmodule ProjectDriveWeb.Resolvers.Schedule do
  @moduledoc """
  Resolvers for schedule schema types
  """

  alias ProjectDrive.{Accounts, Schedule}

  def get_event(%{id: id}, _, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    event = Schedule.get_event(id)

    Bodyguard.permit!(Schedule, :view_event, instructor, event)

    {:ok, event}
  end

  def create_lesson(_parent, %{input: input}, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    student = Accounts.get_student(input.student_id)

    Bodyguard.permit!(Schedule, :create_lesson, instructor, student)

    case Schedule.create_lesson(instructor, input) do
      {:ok, lesson} -> {:ok, %{lesson: lesson}}
      other -> other
    end
  end

  def update_lesson(_parent, %{input: input}, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    lesson = Schedule.get_event(input.id)

    Bodyguard.permit!(Schedule, :update_lesson, instructor, lesson)

    case Schedule.update_lesson(lesson, input) do
      {:ok, lesson} -> {:ok, %{lesson: lesson}}
      other -> other
    end
  end

  def reschedule_lesson(_parent, %{input: input}, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    lesson = Schedule.get_event(input.id)

    Bodyguard.permit!(Schedule, :update_lesson, instructor, lesson)

    case Schedule.update_lesson(lesson, input) do
      {:ok, lesson} -> {:ok, %{lesson: lesson}}
      other -> other
    end
  end

  def delete_lesson(_parent, %{input: %{id: id}}, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    lesson = Schedule.get_event(id)

    Bodyguard.permit!(Schedule, :delete_lesson, instructor, lesson)

    case Schedule.delete_lesson(lesson) do
      {:ok, lesson} -> {:ok, %{id: lesson.id}}
      other -> other
    end
  end

  def get_student(%Schedule.Event{student_id: student_id}, _args, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    student = Accounts.get_student(student_id)

    Bodyguard.permit!(Accounts, :view_student, instructor, student)

    {:ok, student}
  end
end
