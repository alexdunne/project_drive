defmodule ProjectDrive.AccountsTest do
  use ProjectDrive.DataCase

  alias ProjectDrive.Accounts

  describe "users" do
    alias ProjectDrive.Accounts.User

    @valid_attrs %{email: "some email"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "credentials" do
    alias ProjectDrive.Accounts.Credential

    @valid_attrs %{email: "some email", password: "some password"}
    @update_attrs %{email: "some updated email", password: "some updated password"}
    @invalid_attrs %{email: nil, password: nil}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_credential()

      credential
    end

    test "list_credentials/0 returns all credentials" do
      credential = credential_fixture()
      assert Accounts.list_credentials() == [credential]
    end

    test "get_credential!/1 returns the credential with given id" do
      credential = credential_fixture()
      assert Accounts.get_credential!(credential.id) == credential
    end

    test "create_credential/1 with valid data creates a credential" do
      assert {:ok, %Credential{} = credential} = Accounts.create_credential(@valid_attrs)
      assert credential.email == "some email"
      assert credential.password == "some password"
    end

    test "create_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_credential(@invalid_attrs)
    end

    test "update_credential/2 with valid data updates the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{} = credential} = Accounts.update_credential(credential, @update_attrs)
      assert credential.email == "some updated email"
      assert credential.password == "some updated password"
    end

    test "update_credential/2 with invalid data returns error changeset" do
      credential = credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_credential(credential, @invalid_attrs)
      assert credential == Accounts.get_credential!(credential.id)
    end

    test "delete_credential/1 deletes the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{}} = Accounts.delete_credential(credential)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_credential!(credential.id) end
    end

    test "change_credential/1 returns a credential changeset" do
      credential = credential_fixture()
      assert %Ecto.Changeset{} = Accounts.change_credential(credential)
    end
  end

  describe "instructors" do
    alias ProjectDrive.Accounts.Instructor

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def instructor_fixture(attrs \\ %{}) do
      {:ok, instructor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_instructor()

      instructor
    end

    test "list_instructors/0 returns all instructors" do
      instructor = instructor_fixture()
      assert Accounts.list_instructors() == [instructor]
    end

    test "get_instructor!/1 returns the instructor with given id" do
      instructor = instructor_fixture()
      assert Accounts.get_instructor!(instructor.id) == instructor
    end

    test "create_instructor/1 with valid data creates a instructor" do
      assert {:ok, %Instructor{} = instructor} = Accounts.create_instructor(@valid_attrs)
    end

    test "create_instructor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_instructor(@invalid_attrs)
    end

    test "update_instructor/2 with valid data updates the instructor" do
      instructor = instructor_fixture()
      assert {:ok, %Instructor{} = instructor} = Accounts.update_instructor(instructor, @update_attrs)
    end

    test "update_instructor/2 with invalid data returns error changeset" do
      instructor = instructor_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_instructor(instructor, @invalid_attrs)
      assert instructor == Accounts.get_instructor!(instructor.id)
    end

    test "delete_instructor/1 deletes the instructor" do
      instructor = instructor_fixture()
      assert {:ok, %Instructor{}} = Accounts.delete_instructor(instructor)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_instructor!(instructor.id) end
    end

    test "change_instructor/1 returns a instructor changeset" do
      instructor = instructor_fixture()
      assert %Ecto.Changeset{} = Accounts.change_instructor(instructor)
    end
  end

  describe "student_invites" do
    alias ProjectDrive.Accounts.StudentInvite

    @valid_attrs %{email: "some email"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def student_invite_fixture(attrs \\ %{}) do
      {:ok, student_invite} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_student_invite()

      student_invite
    end

    test "list_student_invites/0 returns all student_invites" do
      student_invite = student_invite_fixture()
      assert Accounts.list_student_invites() == [student_invite]
    end

    test "get_student_invite!/1 returns the student_invite with given id" do
      student_invite = student_invite_fixture()
      assert Accounts.get_student_invite!(student_invite.id) == student_invite
    end

    test "create_student_invite/1 with valid data creates a student_invite" do
      assert {:ok, %StudentInvite{} = student_invite} = Accounts.create_student_invite(@valid_attrs)
      assert student_invite.email == "some email"
    end

    test "create_student_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_student_invite(@invalid_attrs)
    end

    test "update_student_invite/2 with valid data updates the student_invite" do
      student_invite = student_invite_fixture()
      assert {:ok, %StudentInvite{} = student_invite} = Accounts.update_student_invite(student_invite, @update_attrs)
      assert student_invite.email == "some updated email"
    end

    test "update_student_invite/2 with invalid data returns error changeset" do
      student_invite = student_invite_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_student_invite(student_invite, @invalid_attrs)
      assert student_invite == Accounts.get_student_invite!(student_invite.id)
    end

    test "delete_student_invite/1 deletes the student_invite" do
      student_invite = student_invite_fixture()
      assert {:ok, %StudentInvite{}} = Accounts.delete_student_invite(student_invite)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_student_invite!(student_invite.id) end
    end

    test "change_student_invite/1 returns a student_invite changeset" do
      student_invite = student_invite_fixture()
      assert %Ecto.Changeset{} = Accounts.change_student_invite(student_invite)
    end
  end
end
