defmodule ProjectDrive.Schedule.Policy do
  @behaviour Bodyguard.Policy

  alias ProjectDrive.{Accounts, Schedule}

  def authorize(:create_lesson, %Accounts.Instructor{} = instructor, %{student_id: student_id}) do
    student = Accounts.get_student(student_id)

    student_belongs_to_instructor(instructor, student)
  end

  def authorize(:update_lesson, %Accounts.Instructor{} = instructor, %Schedule.Event{} = event) do
    student = Accounts.get_student(event.student_id)

    cond do
      !student_belongs_to_instructor(instructor, student) -> false
      !event_belongs_to_instructor(instructor, event) -> false
      true -> true
    end
  end

  def authorize(_, _, _), do: false

  defp student_belongs_to_instructor(%Accounts.Instructor{} = instructor, %Accounts.Student{} = student) do
    instructor.id == student.instructor_id
  end

  defp event_belongs_to_instructor(%Accounts.Instructor{} = instructor, %Schedule.Event{} = event) do
    instructor.id == event.instructor_id
  end
end
