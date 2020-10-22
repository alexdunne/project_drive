defmodule ProjectDriveWeb.Schema do
  @moduledoc """
  Root of the GraphQL schema.

  This module is responsible for merging the fields for each of the area types
  into a single schema
  """

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias ProjectDriveWeb.{Middleware, Resolvers, Schema}

  import_types(Absinthe.Type.Custom)
  import_types(Schema.AuthTypes)
  import_types(Schema.AccountTypes)
  import_types(Schema.ScheduleTypes)

  node interface do
    resolve_type(fn
      %ProjectDrive.Schedule.Event{}, _ ->
        :event

      _, _ ->
        nil
    end)
  end

  query do
    node field do
      resolve(fn
        %{type: :event, id: id}, ctx ->
          Resolvers.Schedule.get_event(%{id: id}, %{}, ctx)

        _, _ ->
          {:error, :not_found}
      end)
    end
  end

  mutation do
    import_fields(:auth_mutations)
    import_fields(:account_mutations)
    import_fields(:schedule_mutations)
  end

  def middleware(middleware, _field, %{identifier: type}) when type in [:query, :subscription, :mutation] do
    Middleware.SafeResolution.apply(middleware) ++ [Middleware.ErrorHandler]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end
end
