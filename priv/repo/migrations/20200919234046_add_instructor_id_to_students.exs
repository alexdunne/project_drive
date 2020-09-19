defmodule ProjectDrive.Repo.Migrations.AddInstructorIdToStudents do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add :instructor_id, references(:instructors, type: :uuid, on_delete: :nothing), null: false
    end
  end
end
