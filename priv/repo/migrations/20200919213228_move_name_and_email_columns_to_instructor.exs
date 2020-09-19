defmodule ProjectDrive.Repo.Migrations.MoveNameAndEmailColumnsToInstructor do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :name
      remove :email
    end

    alter table(:instructors) do
      add :email, :string
      add :name, :string
    end
  end
end
