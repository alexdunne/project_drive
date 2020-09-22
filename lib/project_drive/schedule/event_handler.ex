defmodule ProjectDrive.Schedule.EventHandler do
  use GenServer

  alias ProjectDrive.Schedule

  require Logger

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

  def handle_cast({:"schedule.student_invite.created", _id} = event_shadow, state) do
    %{data: %{student_invite: student_invite}} = EventBus.fetch_event(event_shadow)

    Schedule.send_student_invite_email(student_invite)

    EventBus.mark_as_completed({__MODULE__, event_shadow})

    {:noreply, state}
  end
end
