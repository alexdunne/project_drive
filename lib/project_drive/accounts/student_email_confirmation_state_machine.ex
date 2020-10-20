defmodule ProjectDrive.Accounts.StudentEmailConfirmationStateMachine do
  @moduledoc """
  Controls the progression of accepting an invite as a student
  """
  use Machinery,
    field: :email_confirmation_state,
    states: ["awaiting_confirmation", "confirmed"],
    transitions: %{
      "awaiting_confirmation" => "confirmed"
    }

  alias ProjectDrive.Accounts
  alias ProjectDrive.Accounts.{Student}
end
