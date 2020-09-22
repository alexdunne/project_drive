defmodule ProjectDriveWeb.Resolvers.Account do
  alias ProjectDrive.Accounts

  def create_student_invite(_parent, %{input: %{email: email}}, %{context: %{user: user}}) do
    with instructor <- Accounts.get_instructor_for_user!(user.id),
         {:ok, student_invite} <- Accounts.create_student_invite(instructor, %{email: email}) do
      {:ok, %{student_invite: student_invite}}
    end
  end
end
