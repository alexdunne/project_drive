defmodule ProjectDriveWeb.Resolvers.Schedule do
  alias ProjectDrive.{Accounts, Schedule}

  def create_lesson(_parent, %{input: input}, %{context: %{user: user}}) do
    lesson =
      Accounts.get_instructor_for_user!(user.id)
      |> Schedule.instructor_for_instructor_account()
      |> Schedule.create_lesson(input)

    {:ok, %{lesson: lesson}}
  end

  def get_student(%Schedule.Event{student_id: student_id}, _args, _ctx) do
    student =
      Accounts.get_student(student_id)
      |> Schedule.student_for_student_account()

    {:ok, student}
  end
end
