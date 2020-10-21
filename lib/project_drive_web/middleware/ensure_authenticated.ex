defmodule ProjectDriveWeb.Middleware.EnsureAuthenticated do
  @moduledoc """
  Ensure an authenticated user is making the request
  """

  @behaviour Absinthe.Middleware

  @doc """
  The context is considered authenticated if there is a user present in the `Absinthe.Resolution` `:context`

  ## Examples

  Authenticating using default options:

  object :schedule_mutations do
    @desc "Create lesson"
    field :create_lesson, type: :create_lesson_payload do
      arg(:input, non_null(:create_lesson_input))
      middleware(ProjectDriveWeb.Middleware.EnsureAuthenticated)
    end
  end

  Authenticating using custom options:

  object :schedule_mutations do
    @desc "Create lesson"
    field :create_lesson, type: :create_lesson_payload do
      arg(:input, non_null(:create_lesson_input))
      middleware(ProjectDriveWeb.Middleware.EnsureAuthenticated, error_message: "Not today")
    end
  end
  """
  @impl true
  def call(resolution, opts \\ [])

  def call(%{state: :unresolved} = resolution, opts) do
    defaults = [error_code: :unauthenticated, error_message: :unauthenticated]
    options = Keyword.merge(defaults, opts)

    current_user = resolution.context[:user]

    if current_user == nil do
      Absinthe.Resolution.put_result(
        resolution,
        {:error, %{code: options[:error_code], message: options[:error_message]}}
      )
    else
      resolution
    end
  end

  def call(res, _), do: res
end
