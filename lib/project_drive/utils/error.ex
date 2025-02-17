defmodule ProjectDrive.Utils.Error do
  @moduledoc """
  Source: https://shyr.io/blog/absinthe-exception-error-handling

  Provides a way to normalise errors so they are returned to the user
  in an expected format
  """
  require Logger

  alias __MODULE__

  defstruct [:code, :message, :status_code, :extra]

  @doc """
  Regular errors
  """
  def normalize({:error, reason}) do
    handle(reason)
  end

  @doc """
  Ecto transaction errors
  """
  def normalize({:error, _operation, reason, _changes}) do
    handle(reason)
  end

  @doc """
  Unhandled errors
  """
  def normalize(other) do
    handle(other)
  end

  defp handle(code) when is_atom(code) do
    {status, message} = metadata(code)

    %Error{
      code: code,
      message: message,
      status_code: status
    }
  end

  defp handle(errors) when is_list(errors) do
    Enum.map(errors, &handle/1)
  end

  defp handle(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.map(fn {k, v} ->
      %Error{
        code: :validation,
        message: v,
        status_code: 422,
        extra: %{validation: %{field: k, error: v}}
      }
    end)
  end

  defp handle(other) do
    Logger.error("Unhandled error term:\n#{inspect(other)}")
    handle(:unknown)
  end

  defp metadata(:unknown_resource), do: {400, "Unknown Resource"}
  defp metadata(:invalid_argument), do: {400, "Invalid arguments passed"}
  defp metadata(:unauthenticated), do: {401, "You need to be logged in"}
  defp metadata(:password_hash_missing), do: {401, "Reset your password to login"}
  defp metadata(:incorrect_password), do: {401, "Invalid credentials"}
  defp metadata(:unauthorized), do: {403, "You don't have permission to do that"}
  defp metadata(:not_found), do: {404, "Resource not found"}
  defp metadata(:user_not_found), do: {404, "User not found"}
  defp metadata(:unknown), do: {500, "Something went wrong"}

  defp metadata(code) do
    Logger.warn("Unhandled error code: #{inspect(code)}")
    {422, to_string(code)}
  end
end
