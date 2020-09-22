defmodule ProjectDrive.Schedule do
  @moduledoc """
  The Schedule context.
  """

  import Ecto.Query, warn: false

  alias ProjectDrive.{Identity, Repo, Schedule}
  alias ProjectDrive.Schedule.{Event, Instructor, Student, Policy}

  defdelegate authorize(action, user, params), to: Policy

  def get_instructor(id), do: Repo.get(Instructor, id)

  def get_student(id), do: Repo.get(Student, id)

  def instructor_for_user(%Identity.User{} = user) do
    Repo.get_by(Instructor, user_id: user.id)
  end

  def create_instructor_for_user(%Identity.User{} = user, attrs) do
    Ecto.build_assoc(user, :instructor)
    |> Instructor.changeset(attrs)
    |> Repo.insert()
  end

  def create_student_for_user(%Identity.User{} = user, %Instructor{} = instructor, attrs) do
    Ecto.build_assoc(user, :students, %{instructor: instructor})
    |> Student.changeset(attrs)
    |> Repo.insert()
  end

  def create_lesson(%Instructor{} = instructor, event_attrs) do
    with :ok <- Bodyguard.permit!(Schedule, :create_lesson, instructor, event_attrs) do
      attrs =
        event_attrs
        |> Map.put(:instructor_id, instructor.id)
        |> Map.put(:type, :lesson)

      %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert!()
    end
  end
end
