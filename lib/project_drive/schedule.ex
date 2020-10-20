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

  def get_lessons_which_start_at(starts_at) do
    query =
      from ev in ScheduleEvent,
        where: ev.starts_at == ^starts_at,
        where: ev.type == ^:lesson

    Repo.all(query)
  end

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

  def update_lesson(%Accounts.Instructor{} = instructor, event_id, lesson_attrs) do
    lesson = get_event(event_id)

    with :ok <- Bodyguard.permit!(Schedule, :update_lesson, instructor, lesson) do
      {:ok, updated_lesson} =
        lesson
        |> ScheduleEvent.changeset(lesson_attrs)
        |> Repo.update()

      publish_event(updated_lesson, lesson, :"schedule.lesson.updated")

      {:ok, updated_lesson}
    end
  end

  def delete_lesson(%Accounts.Instructor{} = instructor, id) do
    lesson = get_event(id)

    with :ok <- Bodyguard.permit!(Schedule, :delete_lesson, instructor, lesson) do
      {:ok, lesson} = Repo.delete(lesson)

      publish_event(lesson, :"schedule.lesson.deleted")

      {:ok, lesson}
    end
  end

  def send_new_lesson_notification(%ScheduleEvent{} = lesson) do
    student = Accounts.get_student(lesson.student_id)

    Email.NewLessonNotificationData.new(%{
      student_email: student.email,
      starts_at: lesson.starts_at,
      ends_at: lesson.ends_at
    })
    |> Email.build_notification_email()
    |> Mailer.deliver_now()
  end

  def send_lesson_rescheduled_notification(%ScheduleEvent{} = updated_lesson, %ScheduleEvent{} = original_lesson) do
    student = Accounts.get_student(updated_lesson.student_id)

    Email.LessonRescheduledNotificationData.new(%{
      student_email: student.email,
      previous_starts_at: original_lesson.starts_at,
      new_starts_at: updated_lesson.starts_at,
      new_ends_at: updated_lesson.ends_at
    })
    |> Email.build_notification_email()
    |> Mailer.deliver_now()
  end

  def send_lesson_cancelled_notification(%ScheduleEvent{} = lesson) do
    student = Accounts.get_student(lesson.student_id)

    Email.LessonCancelledNotificationData.new(%{
      student_email: student.email,
      starts_at: lesson.starts_at
    })
    |> Email.build_notification_email()
    |> Mailer.deliver_now()
  end

  def send_lesson_reminder_notification(%ScheduleEvent{} = lesson) do
    student = Accounts.get_student(lesson.student_id)

    Email.LessonReminderData.new(%{
      student_email: student.email,
      starts_at: lesson.starts_at
    })
    |> Email.build_notification_email()
    |> Mailer.deliver_now()
  end

  defp publish_event(%ScheduleEvent{type: :lesson} = lesson, event_name) do
    EventSource.notify %{id: UUID.uuid4(), topic: event_name} do
      %{lesson: lesson}
    end
  end

  defp publish_event(
         %ScheduleEvent{type: :lesson} = updated_lesson,
         %ScheduleEvent{type: :lesson} = original_lesson,
         event_name
       ) do
    EventSource.notify %{id: UUID.uuid4(), topic: event_name} do
      %{updated_lesson: updated_lesson, original_lesson: original_lesson}
    end
  end
end
