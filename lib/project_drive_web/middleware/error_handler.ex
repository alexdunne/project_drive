defmodule ProjectDriveWeb.Middleware.ErrorHandler do
  @moduledoc """
  Source: https://shyr.io/blog/absinthe-exception-error-handling

  Catches thrown errors and formats them in a way Absinthe expects
  """

  @behaviour Absinthe.Middleware

  @impl true
  def call(resolution, _config) do
    errors =
      resolution.errors
      |> Enum.map(&ProjectDrive.Utils.Error.normalize/1)
      |> List.flatten()
      |> Enum.map(&to_absinthe_format/1)

    %{resolution | errors: errors}
  end

  defp to_absinthe_format(%ProjectDrive.Utils.Error{} = error), do: Map.from_struct(error)
  defp to_absinthe_format(error), do: error
end
