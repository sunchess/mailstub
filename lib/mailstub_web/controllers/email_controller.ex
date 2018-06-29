defmodule MailstubWeb.EmailController do
  use MailstubWeb, :controller
  use Mailstub.Auth.Controller

  def show(conn, %{"id" => email_id}, user, _claims) do
    email = from(u in User,
              join: p in assoc(u, :projects),
              join: e in assoc(p, :emails),
              select: e,
              where: e.id == ^email_id, u.id == ^user.id) |> Repo.one

    render conn, "app.html"
  end
end
