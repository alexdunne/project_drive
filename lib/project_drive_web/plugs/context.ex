defmodule ProjectDriveWeb.Plugs.Context do
  @moduledoc """
  Context Plug attaches augments the context based to all resolvers

  The is useful for attaching request specific information such as the current user
  """

  @behaviour Plug

  import Plug.Conn

  alias ProjectDrive.Guardian

  def init(opts) do
    opts
  end

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- authorize(token) do
      %{user: user}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user} <- Guardian.resource_from_claims(claims) do
      {:ok, user}
    else
      _ -> {:error, :unauthorized}
    end
  end
end
