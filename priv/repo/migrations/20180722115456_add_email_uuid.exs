defmodule Mailstub.Repo.Migrations.AddEmailUuid do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION if not exists \"uuid-ossp\"", "DROP EXTENSION \"uuid-ossp\""

    alter table(:emails) do
      add :secret_id, :uuid,  default: fragment("uuid_generate_v4()")
    end
  end
end
