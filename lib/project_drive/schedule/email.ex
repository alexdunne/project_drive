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

  def send_new_lesson_notification(%NewLessonNotificationData{} = data) do
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
end
