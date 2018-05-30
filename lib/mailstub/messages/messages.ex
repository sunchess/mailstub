defmodule Mailstub.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Mailstub.Repo

  alias Mailstub.Messages.Email
  alias Mailstub.Projects.Project

  @doc """
  Creates a email.

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

  @doc """
  List of emails by project.

  ## Examples
      iex> create_message(porject_id)
      [%Emails{project_id: porject_id}, ...]

  """
  def list_emails(project_id) do
    from(Email, where: [project_id: ^project_id]) |> Repo.all
  end
end
