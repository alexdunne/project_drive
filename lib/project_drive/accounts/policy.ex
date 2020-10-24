defmodule ProjectDrive.Accounts.Policy do
  @moduledoc false

  @behaviour Bodyguard.Policy

  alias ProjectDrive.Accounts

  def authorize(:create_student_invite, %Accounts.Instructor{} = _instructor, _), do: true

  def authorize(
        :view_student_invite,
        %Accounts.Instructor{} = instructor,
        %Accounts.StudentInvite{} = student_invite
      ) do
    instructor.id == student_invite.instructor_id
  end

  def authorize(:view_student, %Accounts.Instructor{} = instructor, %Accounts.Student{} = student) do
    instructor.id == student.instructor_id
  end

  def authorize(_, _, _), do: false
end
