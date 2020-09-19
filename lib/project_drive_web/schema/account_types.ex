defmodule ProjectDriveWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation

  alias ProjectDriveWeb.{Resolvers}

  object :student_invite do
    field :email, non_null(:string)
  end

  input_object :create_student_invite_input do
    field :email, non_null(:string)
  end

  object :student_invite_payload do
    field :student_invite, :student_invite
  end

  object :account_mutations do
    @desc "Invite a person to become a Student of the current Instructor"
    field :create_student_invite, :student_invite_payload do
      arg(:input, non_null(:create_student_invite_input))

      resolve(&Resolvers.Account.create_student_invite/3)
    end
  end
end
