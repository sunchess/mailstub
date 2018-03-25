defmodule MailstubWeb.Api.UsersController do
  use MailstubWeb, :controller

  def index(conn, _params) do
    json(conn, %{
      test: "test"
    })
  end
end
