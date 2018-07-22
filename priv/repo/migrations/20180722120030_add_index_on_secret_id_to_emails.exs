defmodule Mailstub.Repo.Migrations.AddIndexOnSecretIdToEmails do
  use Ecto.Migration

  def change do
    create index(:emails, [:secret_id])
  end
end
