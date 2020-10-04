defmodule ProjectDrive.Schedule.EventHandler do
  use GenServer

  require Logger

  alias ProjectDrive.Schedule

  @topics ["^schedule.*"]

  @doc false
  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def init(_opts) do
    EventBus.subscribe({__MODULE__, @topics})
    {:ok, []}
  end

  def process({_topic, _id} = event_shadow) do
    GenServer.cast(__MODULE__, event_shadow)
  end

  def handle_cast({:"schedule.lesson.created", _id} = event_shadow, state) do
    %{data: %{lesson: lesson}} = EventBus.fetch_event(event_shadow)

    Schedule.send_new_lesson_notification(lesson)

    EventBus.mark_as_completed({__MODULE__, event_shadow})

    {:noreply, state}
  end

  def handle_cast({:"schedule.lesson.updated", _id} = event_shadow, state) do
    %{data: %{updated_lesson: updated_lesson, original_lesson: original_lesson}} = EventBus.fetch_event(event_shadow)

    if is_lesson_rescheduled(updated_lesson, original_lesson) do
      Schedule.send_lesson_rescheduled_notification(updated_lesson, original_lesson)
    end

    EventBus.mark_as_completed({__MODULE__, event_shadow})

    {:noreply, state}
  end

  def handle_cast({:"schedule.lesson.deleted", _id} = event_shadow, state) do
    %{data: %{lesson: lesson}} = EventBus.fetch_event(event_shadow)

    Schedule.send_lesson_cancelled_notification(lesson)

    EventBus.mark_as_completed({__MODULE__, event_shadow})

    {:noreply, state}
  end

  defp is_lesson_rescheduled(%Schedule.Event{} = updated_lesson, %Schedule.Event{} = original_lesson) do
    updated_lesson.starts_at != original_lesson.starts_at || updated_lesson.ends_at != original_lesson.ends_at
  end
end
