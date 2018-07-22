defmodule Mailstub.Messages.Email do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mailstub.Projects.Project

  schema "emails" do
    field :body, :map
    field :raw_body, :string
    field :secret_id, :binary_id

    belongs_to :project, Project

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:body, :raw_body])
    |> validate_required([:body])
  end
end
