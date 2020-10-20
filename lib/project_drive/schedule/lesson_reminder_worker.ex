defmodule ProjectDrive.Schedule.LessonReminderWorker do
  @moduledoc """
  Finds all lessons scheduled to start in an hours time and sends reminders to the student
  """

  use Oban.Worker, queue: :default

  require Logger

  alias ProjectDrive.Schedule

  @impl Oban.Worker
  def perform(_args) do
    Logger.info("#{__MODULE__}: Performing task")

    starts_at = Timex.now() |> Timex.shift(hours: 1) |> Timex.set(second: 0)

    lessons = Schedule.get_lessons_which_start_at(starts_at)

    Logger.info("#{__MODULE__}: Found #{length(lessons)} lessons that start at #{starts_at}")

    lessons
    |> Enum.each(fn lesson -> Schedule.send_lesson_reminder_notification(lesson) end)

    :ok
  end
end
