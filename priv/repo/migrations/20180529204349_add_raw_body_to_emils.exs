defmodule Mailstub.Repo.Migrations.AddRawBodyToEmils do
  use Ecto.Migration

  def change do
    alter table("emails") do
      add :raw_body, :text
    end
  end
end
