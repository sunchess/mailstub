defmodule MailstubWeb.PageController do
  use MailstubWeb, :controller

  def index(conn, _params) do
    render conn, "app.html"
  end
end
