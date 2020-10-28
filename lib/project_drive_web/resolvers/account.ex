defmodule ProjectDriveWeb.Resolvers.Account do
  @moduledoc """
  Resolvers for account schema types
  """

  alias ProjectDrive.{Accounts, Schedule}

  def get_student(%Schedule.Event{student_id: student_id}, _args, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)

    do_get_student(instructor, student_id)
  end

  def get_student(%{id: id}, _args, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)

    do_get_student(instructor, id)
  end

  defp do_get_student(%Accounts.Instructor{} = instructor, student_id) do
    student = Accounts.get_student(student_id)

    Bodyguard.permit!(Accounts, :view_student, instructor, student)

    {:ok, student}
  end

  def list_students(_, args, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)

    Accounts.list_students_query(instructor, filters: args)
  end

  def get_student_invite(%{id: id}, _, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)
    student_invite = Accounts.get_student_invite(id)

    Bodyguard.permit!(Accounts, :view_student_invite, instructor, student_invite)

    {:ok, student_invite}
  end

  def create_student_invite(_parent, attrs, %{context: %{user: user}}) do
    instructor = Accounts.get_instructor_for_user!(user.id)

    Bodyguard.permit!(Accounts, :create_student_invite, instructor, attrs)

    case Accounts.create_student_invite(instructor, attrs) do
      {:ok, student_invite, student} -> {:ok, %{student_invite: student_invite, student: student}}
      other -> other
    end
  end
end
