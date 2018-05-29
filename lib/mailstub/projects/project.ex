defmodule Mailstub.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mailstub.Accounts.User
  alias Mailstub.Messages.Email


  schema "projects" do
    field :name, :string
    field :key, :binary_id
    field :secret, :binary_id

    belongs_to :user, User
    has_many :emails, Email, on_delete: :delete_all
    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
