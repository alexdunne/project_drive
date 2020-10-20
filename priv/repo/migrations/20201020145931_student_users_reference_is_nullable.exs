defmodule ProjectDrive.Repo.Migrations.StudentUsersReferenceIsNullable do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE students DROP CONSTRAINT students_user_id_fkey"

    alter table(:students) do
      modify :user_id, references(:users, type: :uuid, on_delete: :nothing), null: true
    end
  end
end
