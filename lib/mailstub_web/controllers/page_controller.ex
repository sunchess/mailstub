defmodule MailstubWeb.PageController do
  use MailstubWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
