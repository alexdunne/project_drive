defmodule ProjectDrive.Repo.Migrations.AddTokenAndExpiresAtFieldsToStudentInvites do
  use Ecto.Migration

  def change do
    alter table(:student_invites) do
      add :token, :string, null: false
      add :expires_at, :utc_datetime, null: false
    end
  end
end
