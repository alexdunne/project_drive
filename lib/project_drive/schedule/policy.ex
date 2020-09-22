defmodule ProjectDrive.Schedule.Policy do
  @behaviour Bodyguard.Policy

  alias ProjectDrive.{Accounts}

  def authorize(:create_lesson, %Accounts.Instructor{} = instructor, %{student_id: student_id}) do
    student = Accounts.get_student(student_id)

    instructor.id == student.instructor_id
  end

  def authorize(_, _, _), do: false
end
