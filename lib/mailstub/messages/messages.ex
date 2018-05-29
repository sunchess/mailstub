defmodule Mailstub.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Mailstub.Repo

  alias Mailstub.Messages.Email
  alias Mailstub.Projects.Project

  @doc """
  Creates a project.

  ## Examples
      iex> create_message(project, %{field: value})
      {:ok, %Email{}}

      iex> create_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(%Project{} = project, attrs \\ %{}) do
    %Email{}
    |> Email.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:project, project)
    |> Repo.insert()
  end
end
