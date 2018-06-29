defmodule MailstubWeb.Api.EmailController do
  use MailstubWeb, :controller
  use Mailstub.Auth.Controller
  alias Mailstub.Messages
  alias MailstubWeb.Projects.Project

  action_fallback MailstubWeb.FallbackController

  def index(conn, %{"project_id"=>project_id}, user, _claims) do
    emails = Messages.list_emails(user, project_id)
    render(conn, "index.json", emails: emails)
  end
end
