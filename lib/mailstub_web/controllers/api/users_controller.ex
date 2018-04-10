defmodule MailstubWeb.Api.UsersController do
  use MailstubWeb, :controller

  alias Mailstub.Accounts
  alias Mailstub.Accounts.User

  action_fallback MailstubWeb.FallbackController

  def index(conn, _params) do
    json(conn, %{
      test: "test"
    })
  end

  def create(conn, params) do
    with {:ok, %User{} = user} <- Accounts.create_user(params),
         {:ok, token, _} = Mailstub.Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", "/")
      |> render("show.json", user: user, token: token)
    end
  end
end
