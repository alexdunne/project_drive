defmodule ProjectDrive.Accounts.Loader do
  alias ProjectDrive.Accounts

  def data() do
    Dataloader.KV.new(&fetch/2)
  end

  def fetch({:student, %{user: user}}, events) do
    instructor = Accounts.get_instructor_for_user!(user.id)

    student_ids = Enum.map(events, & &1.student_id)

    students_by_id =
      Accounts.get_students(instructor, student_ids)
      |> Enum.reduce(%{}, fn student, acc ->
        Map.put(acc, student.id, student)
      end)

    events
    |> Enum.reduce(%{}, fn event, acc ->
      student = Map.get(students_by_id, event.student_id)
      Map.put(acc, event, student)
    end)
  end
end
