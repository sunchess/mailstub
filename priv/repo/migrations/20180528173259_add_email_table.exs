defmodule Mailstub.Repo.Migrations.AddEmailTable do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :project_id, references(:projects, on_delete: :delete_all)
      add :body, :map

      timestamps()
    end

    create index(:emails, [:project_id])
    drop_if_exists index(:projects, [:key, :secret])
    create index(:projects, [:key])
  end
end
