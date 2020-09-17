defmodule ProjectDrive.Repo.Migrations.CreateInstructors do
  use Ecto.Migration

  def change do
    create table(:instructors, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:instructors, [:user_id])
  end
end
