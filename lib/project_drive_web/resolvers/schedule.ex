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

  def list_events(_, args, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)

    Schedule.list_events(instructor, filters: args)
  end

  def has_conflicts(_, args, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)

    Schedule.has_conflicts(instructor, args)
  end

  def create_lesson(_parent, input, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    student = Accounts.get_student(input.student_id)

    Bodyguard.permit!(Schedule, :create_lesson, instructor, student)

    case Schedule.create_lesson(instructor, input) do
      {:ok, lesson} -> {:ok, %{lesson: lesson}}
      other -> other
    end
  end

  def update_lesson(_parent, input, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    lesson = Schedule.get_event(input.lesson_id)

    Bodyguard.permit!(Schedule, :update_lesson, instructor, lesson)

    case Schedule.update_lesson(lesson, input) do
      {:ok, lesson} -> {:ok, %{lesson: lesson}}
      other -> other
    end
  end

  def reschedule_lesson(_parent, input, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    lesson = Schedule.get_event(input.lesson_id)

    Bodyguard.permit!(Schedule, :update_lesson, instructor, lesson)

    case Schedule.update_lesson(lesson, input) do
      {:ok, lesson} -> {:ok, %{lesson: lesson}}
      other -> other
    end
  end

  def delete_lesson(_parent, %{lesson_id: id}, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    lesson = Schedule.get_event(id)

    Bodyguard.permit!(Schedule, :delete_lesson, instructor, lesson)

    case Schedule.delete_lesson(lesson) do
      {:ok, lesson} -> {:ok, %{id: lesson.id}}
      other -> other
    end
  end
end
