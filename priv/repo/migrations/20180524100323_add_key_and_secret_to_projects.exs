defmodule Mailstub.Repo.Migrations.AddKeyAndSecretToProjects do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION if not exists \"uuid-ossp\"", "DROP EXTENSION \"uuid-ossp\""

    alter table(:projects) do
      add :key, :uuid,  default: fragment("uuid_generate_v4()")
      add :secret, :uuid,  default: fragment("uuid_generate_v4()")
    end

    create index(:projects, [:key, :secret])
  end
end
