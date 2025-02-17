defmodule ProjectDrive.Schedule do
  @moduledoc """
  The Schedule context.
  """

  import Ecto.Query, warn: false

  alias ProjectDrive.{Accounts, Mailer, Schedule, Repo}
  alias ProjectDrive.Schedule.{Email, Policy}

  use EventBus.EventSource

  defdelegate authorize(action, user, params), to: Policy

  def get_event(id), do: Repo.get(Schedule.Event, id)

  def list_events(%Accounts.Instructor{} = instructor, opts \\ []) do
    Schedule.Event
    |> Schedule.Event.filter_by_instructor(instructor)
    |> Schedule.Event.filter(opts[:filters])
    |> Schedule.Event.order_events_asc()
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, opts[:filters])
  end

  def get_lessons_which_start_at(starts_at) do
    query =
      from ev in Schedule.Event,
        where: ev.starts_at == ^starts_at,
        where: ev.type == ^:lesson

    Repo.all(query)
  end

  def has_conflicts(%Accounts.Instructor{} = instructor, %{starts_at: starts_at, ends_at: ends_at}) do
    conflicts =
      Schedule.Event
      |> Schedule.Event.filter_by_instructor(instructor)
      |> Schedule.Event.select_conflicts_count(%{starts_at: starts_at, ends_at: ends_at})
      |> Repo.one()

    {:ok, %{has_conflicts: conflicts > 0}}
  end

  def create_lesson(%Accounts.Instructor{} = instructor, lesson_attrs) do
    attrs =
      lesson_attrs
      |> Map.put(:instructor_id, instructor.id)
      |> Map.put(:type, :lesson)

    %Schedule.Event{}
    |> Schedule.Event.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, lesson} ->
        publish_event(lesson, :"schedule.lesson.created")
        {:ok, lesson}

      other ->
        other
    end
  end

  def update_lesson(%Schedule.Event{} = lesson, lesson_attrs) do
    lesson
    |> Schedule.Event.changeset(lesson_attrs)
    |> Repo.update()
    |> case do
      {:ok, updated_lesson} ->
        publish_event(updated_lesson, lesson, :"schedule.lesson.updated")
        {:ok, updated_lesson}

      other ->
        other
    end
  end

  def delete_lesson(%Schedule.Event{} = lesson) do
    Repo.delete(lesson)
    |> case do
      {:ok, lesson} ->
        publish_event(lesson, :"schedule.lesson.deleted")
        {:ok, lesson}

      other ->
        other
    end
  end

  def send_new_lesson_notification(%Schedule.Event{} = lesson) do
    student = Accounts.get_student(lesson.student_id)

    if student.email_confirmation_state == "confirmed" do
      Email.NewLessonNotificationData.new(%{
        student_email: student.email,
        starts_at: lesson.starts_at,
        ends_at: lesson.ends_at
      })
      |> Email.build_notification_email()
      |> Mailer.deliver_now()
    end
  end

  def send_lesson_rescheduled_notification(%Schedule.Event{} = updated_lesson, %Schedule.Event{} = original_lesson) do
    student = Accounts.get_student(updated_lesson.student_id)

    if student.email_confirmation_state == "confirmed" do
      Email.LessonRescheduledNotificationData.new(%{
        student_email: student.email,
        previous_starts_at: original_lesson.starts_at,
        new_starts_at: updated_lesson.starts_at,
        new_ends_at: updated_lesson.ends_at
      })
      |> Email.build_notification_email()
      |> Mailer.deliver_now()
    end
  end

  def send_lesson_cancelled_notification(%Schedule.Event{} = lesson) do
    student = Accounts.get_student(lesson.student_id)

    if student.email_confirmation_state == "confirmed" do
      Email.LessonCancelledNotificationData.new(%{
        student_email: student.email,
        starts_at: lesson.starts_at
      })
      |> Email.build_notification_email()
      |> Mailer.deliver_now()
    end
  end

  def send_lesson_reminder_notification(%Schedule.Event{} = lesson) do
    student = Accounts.get_student(lesson.student_id)

    if student.email_confirmation_state == "confirmed" do
      Email.LessonReminderData.new(%{
        student_email: student.email,
        starts_at: lesson.starts_at
      })
      |> Email.build_notification_email()
      |> Mailer.deliver_now()
    end
  end

  defp publish_event(%Schedule.Event{type: :lesson} = lesson, event_name) do
    EventSource.notify %{id: UUID.uuid4(), topic: event_name} do
      %{lesson: lesson}
    end
  end

  defp publish_event(
         %Schedule.Event{type: :lesson} = updated_lesson,
         %Schedule.Event{type: :lesson} = original_lesson,
         event_name
       ) do
    EventSource.notify %{id: UUID.uuid4(), topic: event_name} do
      %{updated_lesson: updated_lesson, original_lesson: original_lesson}
    end
  end
end
