defmodule ProjectDrive.Schedule do
  @moduledoc """
  The Schedule context.
  """

  import Ecto.Query, warn: false

  alias ProjectDrive.{Accounts, Mailer, Repo, Schedule}
  alias ProjectDrive.Schedule.{Email, Policy}

  # aliased as EventBus.EventSource also has an Event module
  alias ProjectDrive.Schedule.Event, as: ScheduleEvent

  use EventBus.EventSource

  defdelegate authorize(action, user, params), to: Policy

  def get_event(id), do: Repo.get(ScheduleEvent, id)

  def create_lesson(%Accounts.Instructor{} = instructor, lesson_attrs) do
    with :ok <- Bodyguard.permit!(Schedule, :create_lesson, instructor, lesson_attrs) do
      attrs =
        lesson_attrs
        |> Map.put(:instructor_id, instructor.id)
        |> Map.put(:type, :lesson)

      {:ok, lesson} =
        %ScheduleEvent{}
        |> ScheduleEvent.changeset(attrs)
        |> Repo.insert()

      publish_event(lesson, :"schedule.lesson.created")

      {:ok, lesson}
    end
  end

  def update_lesson(%Accounts.Instructor{} = instructor, %{id: event_id} = lesson_attrs) do
    event = get_event(event_id)

    with :ok <- Bodyguard.permit!(Schedule, :update_lesson, instructor, event) do
      event
      |> ScheduleEvent.changeset(lesson_attrs)
      |> Repo.update()
    end
  end

  def delete_lesson(%Accounts.Instructor{} = instructor, id) do
    event = get_event(id)

    with :ok <- Bodyguard.permit!(Schedule, :delete_lesson, instructor, event) do
      event
      |> Repo.delete()
    end
  end

  def send_new_lesson_notification(%ScheduleEvent{} = lesson) do
    student = Accounts.get_student(lesson.student_id)

    Email.NewLessonNotificationData.new(%{
      student_email: student.email,
      starts_at: lesson.starts_at,
      ends_at: lesson.ends_at
    })
    |> Email.send_new_lesson_notification()
    |> Mailer.deliver_now()
  end

  defp publish_event(%ScheduleEvent{type: :lesson} = lesson, event_name) do
    EventSource.notify %{id: UUID.uuid4(), topic: event_name} do
      %{lesson: lesson}
    end
  end
end
