defmodule Mailstub.Repo.Migrations.AddAttachment do
  use Ecto.Migration

  def change do
    create table(:attachments) do
      add :email_id, references(:emails, on_delete: :delete_all)
      add :filename, :varchar
      add :content_transfer_encoding, :varchar
      add :content_type, :varchar
      add :content_id, :varchar
      add :url, :varchar
    end
  end
end
