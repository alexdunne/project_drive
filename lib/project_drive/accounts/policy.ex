defmodule ProjectDrive.Accounts.Policy do
  @moduledoc false

  @behaviour Bodyguard.Policy

  alias ProjectDrive.Accounts.{Instructor, Student}

  def authorize(:create_student_invite, %Instructor{} = _instructor, _), do: true

  def authorize(:view_student, %Instructor{} = instructor, %Student{} = student) do
    instructor.id == student.instructor_id
  end

  def authorize(_, _, _), do: false
end
