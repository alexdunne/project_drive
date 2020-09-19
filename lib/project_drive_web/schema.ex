defmodule ProjectDriveWeb.Schema do
  use Absinthe.Schema

  alias ProjectDriveWeb.{Schema}

  import_types(Schema.AuthTypes)
  import_types(Schema.AccountTypes)

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
  end
end
