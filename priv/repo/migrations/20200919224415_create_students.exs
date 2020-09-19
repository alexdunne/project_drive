defmodule ProjectDrive.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string
      add :name, :string

      add :user_id, references(:users, type: :uuid, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:students, [:user_id])
  end
end
