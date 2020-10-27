defmodule ProjectDriveWeb.Schema.AccountTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ProjectDriveWeb.Middleware.{EnsureAuthenticated}
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

  input_object :create_student_invite_input do
    field :email, non_null(:string)
    field :name, non_null(:string)
  end

  object :student_invite_payload do
    field :student, :student
    field :student_invite, :student_invite
  end

  object :account_queries do
    connection field :students, node_type: :student do
      arg(:search_term, :string)

      middleware(EnsureAuthenticated)

      resolve(&Resolvers.Account.list_students/3)
    end
  end

  object :account_mutations do
    @desc "Invite a person to become a Student of the current Instructor"
    field :create_student_invite, :student_invite_payload do
      arg(:input, non_null(:create_student_invite_input))

      middleware(EnsureAuthenticated)

      resolve(&Resolvers.Account.create_student_invite/3)
    end
  end
end
