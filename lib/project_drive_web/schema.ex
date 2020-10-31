defmodule ProjectDriveWeb.Schema do
  @moduledoc """
  Root of the GraphQL schema.

  This module is responsible for merging the fields for each of the area types
  into a single schema
  """

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias ProjectDrive.{Accounts}
  alias ProjectDriveWeb.{Middleware, Resolvers, Schema}

  import_types(Absinthe.Type.Custom)
  import_types(Schema.AuthTypes)
  import_types(Schema.AccountTypes)
  import_types(Schema.ScheduleTypes)

  def context(ctx) do
    loader =
      Dataloader.new()
      # |> Dataloader.add_source(:student, Dataloader.KV.new(&Accounts.Loader.fetch_students/2))
      |> Dataloader.add_source(:student, Accounts.Loader.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins() do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  node interface do
    resolve_type(fn
      %ProjectDrive.Accounts.Student{}, _ ->
        :student

      %ProjectDrive.Accounts.StudentInvite{}, _ ->
        :student_invite

      %ProjectDrive.Schedule.Event{}, _ ->
        :event

      _, _ ->
        nil
    end)
  end

  query do
    node field do
      resolve(fn
        %{type: :student, id: id}, ctx ->
          Resolvers.Account.get_student(%{id: id}, %{}, ctx)

        %{type: :student_invite, id: id}, ctx ->
          Resolvers.Account.get_student_invite(%{id: id}, %{}, ctx)

        %{type: :event, id: id}, ctx ->
          Resolvers.Schedule.get_event(%{id: id}, %{}, ctx)

        _, _ ->
          {:error, :not_found}
      end)
    end

    import_fields(:account_queries)
    import_fields(:schedule_queries)
  end

  mutation do
    import_fields(:auth_mutations)
    import_fields(:account_mutations)
    import_fields(:schedule_mutations)
  end

  # Which globally unique ids do we need to convert to DB ids
  @node_id_rules [
    input: [student_id: :student]
  ]

  def middleware(middleware, _field, %{identifier: type}) when type in [:query, :subscription, :mutation] do
    middleware = Middleware.SafeResolution.apply(middleware) ++ [Middleware.ErrorHandler]

    [{Absinthe.Relay.Node.ParseIDs, @node_id_rules} | middleware]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end
end
