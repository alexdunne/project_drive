defmodule ProjectDriveWeb.Resolvers.Schedule do
  alias ProjectDrive.{Accounts, Schedule}

  def create_lesson(_parent, %{input: input}, %{context: %{user: user}}) do
    lesson =
      Accounts.get_instructor_for_user!(user.id)
      |> Schedule.create_lesson(input)

    {:ok, %{lesson: lesson}}
  end

  def get_student(%Schedule.Event{student_id: student_id}, _args, _ctx) do
    student = Accounts.get_student(student_id)

    {:ok, student}
  end
end
