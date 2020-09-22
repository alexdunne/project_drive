defmodule ProjectDrive.Schedule.Policy do
  @behaviour Bodyguard.Policy

  alias ProjectDrive.{Accounts, Schedule}
  alias ProjectDrive.Schedule.Instructor

  def authorize(:create_lesson, %Instructor{} = instructor, %{student_id: student_id}) do
    student =
      Accounts.get_student(student_id)
      |> Schedule.student_for_student_account()

    instructor.id == student.instructor_id
  end

  def authorize(_, _, _), do: false
end
