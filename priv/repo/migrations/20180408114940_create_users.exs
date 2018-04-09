defmodule Mailstub.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :crypted_password, :string

      timestamps()
    end


    create index("users", [:email])
  end
end
