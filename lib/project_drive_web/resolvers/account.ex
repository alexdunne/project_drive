defmodule ProjectDriveWeb.Resolvers.Account do
  @moduledoc """
  Resolvers for account schema types
  """

  alias ProjectDrive.Accounts

  def create_student_invite(_parent, %{input: attrs}, %{context: %{user: user}}) do
    with instructor <- Accounts.get_instructor_for_user!(user.id),
         {:ok, student_invite, student} <- Accounts.create_student_invite(instructor, attrs) do
      {:ok, %{student_invite: student_invite, student: student}}
    end
  end
end
