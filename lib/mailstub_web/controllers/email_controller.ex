defmodule MailstubWeb.EmailController do
  use MailstubWeb, :controller
  import Ecto.Query

  alias Mailstub.Messages.Email
  alias Mailstub.Repo

  plug :put_layout, "clean.html"

  def show(conn, %{"id" => secret_id}) do
    email = Repo.get_by!(Email, secret_id: secret_id)

    render conn, "show.html", email: email
  end
end
