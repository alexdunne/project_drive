defmodule ProjectDriveWeb.Middleware.SafeResolution do
  @moduledoc """
  Source: https://shyr.io/blog/absinthe-exception-error-handling

  Wraps other middleware to catch errors rather than letting them propagate to the response
  """

  alias Absinthe.Resolution
  require Logger

  @behaviour Absinthe.Middleware

  @doc """
  Call this on existing middleware to replace instances of
  `Resolution` middleware with `SafeResolution`

  ## Examples

  Normal usage

  def middleware(middleware, _field, %{identifier: type}) when type in [:query, :mutation] do
    SafeResolution.apply(middleware)
  end
  """
  def apply(middleware) when is_list(middleware) do
    Enum.map(middleware, fn
      {{Resolution, :call}, resolver} -> {__MODULE__, resolver}
      other -> other
    end)
  end

  @impl true
  def call(resolution, resolver) do
    Resolution.call(resolution, resolver)
  rescue
    e in Bodyguard.NotAuthorizedError ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      Resolution.put_result(resolution, {:error, :unauthorized})

    e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      Resolution.put_result(resolution, {:error, :unknown})
  end
end
