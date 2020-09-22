defmodule ProjectDriveWeb.Schema do
  use Absinthe.Schema

  alias ProjectDriveWeb.{Schema}

  import_types(Absinthe.Type.Custom)
  import_types(Schema.AuthTypes)
  import_types(Schema.AccountTypes)
  import_types(Schema.ScheduleTypes)

  query do
    field :test, :string do
      resolve(fn _, _ ->
        {:ok, "hi"}
      end)
    end
  end

  mutation do
    import_fields(:auth_mutations)
    import_fields(:account_mutations)
    import_fields(:schedule_mutations)
  end
end
