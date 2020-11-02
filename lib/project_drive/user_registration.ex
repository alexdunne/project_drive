defmodule ProjectDrive.UserRegistration do
  @moduledoc """
  UserRegistration is responsible for creating new users and any potential profiles
  such as Instructor or Student
  """

  alias Ecto.Multi
  alias ProjectDrive.{Accounts, Identity, Repo}

  def register_instructor(params) do
    Multi.new()
    |> Multi.run(:user, fn _repo, _changes -> Identity.create_new_user(params) end)
    |> Multi.run(:instructor, fn _repo, %{user: user} ->
      {:ok, Accounts.ensure_instructor_exists(user)}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _operation, changeset, _changes} -> {:error, changeset}
      other -> other
    end
  end

  def register_student_from_invite(params) do
    with {:ok, invite} <- Accounts.get_student_invite_by_token(params.token),
         instructor <- Accounts.get_instructor(invite.instructor_id) do
      user_params = %{email: invite.email, password: params.password}

      Multi.new()
      |> Multi.run(:student, fn _, _ ->
        {:ok, Accounts.get_student_by_email(instructor, invite.email)}
      end)
      |> Multi.run(:user, fn _, _ -> Identity.create_new_user(user_params) end)
      |> Multi.run(:associate_user, fn _, %{user: user, student: student} ->
        associate_student_with_user(user, student)
      end)
      |> Multi.run(:expire_student_invite, fn _, _ -> Accounts.expire_student_invite(invite) end)
      |> Multi.run(:update_email_confirmation_state, fn _, %{student: student} ->
        Accounts.mark_student_email_as_confirmed(student)
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{user: user}} -> {:ok, user}
        {:error, _operation, changeset, _} -> {:error, changeset}
        other -> other
      end
    end
  end

  defp associate_student_with_user(%Identity.User{} = user, %Accounts.Student{} = student) do
    student
    |> Repo.preload(:user)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.update()
  end
end
