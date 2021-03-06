defmodule Mailstub.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mailstub.Projects.Project

  schema "users" do
    field :crypted_password, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :projects, Project, on_delete: :delete_all
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> set_password(attrs)
  end

  def check_password(password, user) do
    Comeonin.Bcrypt.checkpw(password, user.crypted_password)
  end

  #private

  #if we need to change the password
  defp set_password(changeset, params) do
    if is_binary(params["password"]) and String.length(params["password"]) > 0 do
      changeset
      |> put_change(:crypted_password, hashed_password(params["password"]))
    else
      changeset
    end
  end

  defp hashed_password(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end

end
