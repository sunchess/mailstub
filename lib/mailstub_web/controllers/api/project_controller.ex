defmodule MailstubWeb.Api.ProjectController do
  use MailstubWeb, :controller
  use Mailstub.Auth.Controller

  alias Mailstub.Projects.Project
  alias Mailstub.Projects

  action_fallback MailstubWeb.FallbackController
  #plug Guardian.Plug.EnsureAuthenticated

  def index(conn, _params, user, _claims) do
    projects = Projects.list_projects(user)
    render(conn, "index.json", projects: projects)
  end

  def create(conn, %{"project" => project_params}, user, _claims) do
    with {:ok, %Project{} = project} <- Projects.create_project(user, project_params) do
      conn
      |> put_status(:created)
      #|> put_resp_header("location", api_project_path(conn, :show, project))
      |> render("show.json", project: project)
    end
  end

  def show(conn, %{"id" => id}, user, _claims) do
    project = Projects.get_project!(id) |> Repo.preload(:emails)
    IO.inspect(project)
    render(conn, "show.json", project: project)
  end

  def update(conn, %{"id" => id, "project" => project_params}, user, _claims) do
    project = Projects.get_project!(id)

    with {:ok, %Project{} = project} <- Projects.update_project(project, project_params) do
      render(conn, "show.json", project: project)
    end
  end

  def delete(conn, %{"id" => id}, user, _claims) do
    project = Projects.get_project!(id)
    with {:ok, %Project{}} <- Projects.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end
end
