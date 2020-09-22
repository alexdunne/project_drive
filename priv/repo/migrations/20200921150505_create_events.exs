defmodule ProjectDrive.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :starts_at, :utc_datetime, null: false
      add :ends_at, :utc_datetime, null: false
      add :type, :integer, null: false
      add :notes, :string
      add :instructor_id, references(:instructors, type: :uuid, on_delete: :nothing), null: false
      add :student_id, references(:students, type: :uuid, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:events, [:instructor_id])
    create index(:events, [:student_id])
  end
end
