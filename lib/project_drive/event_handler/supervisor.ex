defmodule ProjectDrive.EventHandler.Supervisor do
  @moduledoc """
  Supervises all EventHandlers across various contexts
  """
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      ProjectDrive.Schedule.EventHandler
    ]

    supervise(children, strategy: :one_for_one)
  end
end
