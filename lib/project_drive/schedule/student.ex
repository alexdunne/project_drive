defmodule ProjectDrive.Schedule.Student do
  @enforce_keys [:id, :name, :email, :instructor_id]
  defstruct [:id, :name, :email, :instructor_id]
end
