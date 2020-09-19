defmodule ProjectDrive.Accounts.Policy do
  @behaviour Bodyguard.Policy

  alias ProjectDrive.Accounts.Instructor

  def authorize(:create_student_invite, %Instructor{} = _instructor, _), do: true

  def authorize(_, _, _), do: false
end
