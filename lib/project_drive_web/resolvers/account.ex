defmodule ProjectDriveWeb.Resolvers.Account do
  alias ProjectDrive.Schedule

  def create_student_invite(_parent, %{input: %{email: email}}, %{context: %{user: user}}) do
    with instructor <- Schedule.instructor_for_user(user),
         {:ok, student_invite} <- Schedule.create_student_invite(instructor, %{email: email}) do
      {:ok, %{student_invite: student_invite}}
    end
  end
end
