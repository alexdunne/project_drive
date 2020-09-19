defmodule ProjectDrive.Repo.Migrations.CreateStudentInvites do
  use Ecto.Migration

  def change do
    create table(:student_invites, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string

      add :instructor_id, references(:instructors, type: :uuid, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create unique_index(:student_invites, [:email, :instructor_id])
    create index(:student_invites, [:instructor_id])
  end
end
