defmodule Mailstub.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mailstub.Accounts.User


  schema "projects" do
    field :name, :string
    field :key, :binary_id
    field :secret, :binary_id

    belongs_to :user, User
    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
