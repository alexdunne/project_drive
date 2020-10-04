defmodule ProjectDrive.Schedule.Email do
  import Bamboo.Email

  require Logger

  @sender_email Application.fetch_env!(:project_drive, :sender_email)

  defmodule NewLessonNotificationData do
    @enforce_keys [:student_email, :starts_at, :ends_at]
    defstruct [:student_email, :starts_at, :ends_at]

    def new(attrs) do
      %NewLessonNotificationData{
        student_email: attrs.student_email,
        starts_at: attrs.starts_at,
        ends_at: attrs.ends_at
      }
    end
  end

  defmodule LessonRescheduledNotificationData do
    @enforce_keys [:student_email, :previous_starts_at, :new_starts_at, :new_ends_at]
    defstruct [:student_email, :previous_starts_at, :new_starts_at, :new_ends_at]

    def new(attrs) do
      %LessonRescheduledNotificationData{
        student_email: attrs.student_email,
        previous_starts_at: attrs.previous_starts_at,
        new_starts_at: attrs.new_starts_at,
        new_ends_at: attrs.new_ends_at
      }
    end
  end

  defmodule LessonCancelledNotificationData do
    @enforce_keys [:student_email, :starts_at]
    defstruct [:student_email, :starts_at]

    def new(attrs) do
      %LessonCancelledNotificationData{
        student_email: attrs.student_email,
        starts_at: attrs.starts_at
      }
    end
  end

  def build_notification_email(%NewLessonNotificationData{} = data) do
    Logger.info(fn ->
      Logger.info("Creating a new lesson notification for:")
      inspect(data)
    end)

    {:ok, formatted_lesson_starts_at} = Timex.format(data.starts_at, "{WDfull}, {D} {Mshort} at {h24}:{m}")

    duration = Timex.diff(data.ends_at, data.starts_at, :minutes)

    body =
      "Your instructor has booked a new lesson for #{formatted_lesson_starts_at}. This lesson is for #{duration} minutes"

    new_email(
      to: data.student_email,
      from: @sender_email,
      subject: "Lesson booked confirmation",
      html_body: body,
      text_body: body
    )
  end

  def build_notification_email(%LessonRescheduledNotificationData{} = data) do
    Logger.info(fn ->
      Logger.info("Creating a lesson reschedule notification for:")
      inspect(data)
    end)

    {:ok, formatted_previous_starts_at} = Timex.format(data.previous_starts_at, "{WDfull}, {D} {Mshort} at {h24}:{m}")
    {:ok, formatted_new_starts_at} = Timex.format(data.new_starts_at, "{WDfull}, {D} {Mshort} at {h24}:{m}")

    duration = Timex.diff(data.new_ends_at, data.new_starts_at, :minutes)

    body =
      "Your lesson that was originally scheduled for #{formatted_previous_starts_at} has been rescheduled for #{
        formatted_new_starts_at
      }. Your lesson is for #{duration} minutes"

    new_email(
      to: data.student_email,
      from: @sender_email,
      subject: "Lesson rescheduled",
      html_body: body,
      text_body: body
    )
  end

  def build_notification_email(%LessonCancelledNotificationData{} = data) do
    Logger.info(fn ->
      Logger.info("Creating a lesson cancelled notification for:")
      inspect(data)
    end)

    {:ok, formatted_lesson_starts_at} = Timex.format(data.starts_at, "{WDfull}, {D} {Mshort} at {h24}:{m}")

    body = "Your instructor has cancelled your #{formatted_lesson_starts_at} lesson."

    new_email(
      to: data.student_email,
      from: @sender_email,
      subject: "Lesson #{formatted_lesson_starts_at} cancelled",
      html_body: body,
      text_body: body
    )
  end

  def build_notification_email(data) do
    Logger.info(fn ->
      inspect(data)
    end)

    raise "The notification type is not supported"
  end
end
