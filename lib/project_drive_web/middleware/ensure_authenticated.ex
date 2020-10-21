defmodule ProjectDriveWeb.Middleware.EnsureAuthenticated do
  @moduledoc """
  Ensure an authenticated user is making the request
  """

  @behaviour Absinthe.Middleware

  @doc """
  The context is considered authenticated if there is a user present in the `Absinthe.Resolution` `:context`

  ## Example

  object :schedule_mutations do
    @desc "Create lesson"
    field :create_lesson, type: :create_lesson_payload do
      arg(:input, non_null(:create_lesson_input))
      middleware(ProjectDriveWeb.Middleware.EnsureAuthenticated)
    end
  end
  """
  @impl true
  def call(resolution, opts \\ [])

  def call(%{state: :unresolved} = resolution, _opts) do
    current_user = resolution.context[:user]

    if current_user == nil do
      Absinthe.Resolution.put_result(
        resolution,
        {:error, :unauthenticated}
      )
    else
      resolution
    end
  end
end
