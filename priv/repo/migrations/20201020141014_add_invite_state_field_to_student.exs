defmodule ProjectDrive.Repo.Migrations.AddEmailConfirmationStateFieldToStudent do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add :email_confirmation_state, :string
    end
  end
end
