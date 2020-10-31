defmodule ProjectDriveWeb.Schema.AccountTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ProjectDriveWeb.{Resolvers}

  node object(:student_invite) do
    field :name, non_null(:string)
    field :email, non_null(:string)
  end

  node object(:student) do
    field :email, non_null(:string)
    field :name, non_null(:string)
  end

  connection(node_type: :student)

  object :account_queries do
    connection field :students, node_type: :student do
      arg(:search_term, :string)

      resolve(&Resolvers.Account.list_students/3)
    end
  end

  object :account_mutations do
    @desc "Invite a person to become a Student of the current Instructor"
    payload field :create_student_invite do
      input do
        field :email, non_null(:string)
        field :name, non_null(:string)
      end

      output do
        field :student, :student
        field :student_invite, :student_invite
      end

      resolve(&Resolvers.Account.create_student_invite/3)
    end
  end
end
