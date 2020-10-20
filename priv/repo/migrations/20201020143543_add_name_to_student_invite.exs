defmodule ProjectDrive.Repo.Migrations.AddNameToStudentInvite do
  use Ecto.Migration

  def change do
    alter table(:student_invites) do
      add :name, :string
    end
  end
end
