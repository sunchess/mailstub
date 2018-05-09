defmodule MailstubWeb.Api.SessionController do
  use MailstubWeb, :controller

  alias Mailstub.Accounts
  alias Mailstub.Accounts.User

  action_fallback MailstubWeb.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Accounts.auth(email, password),
         {:ok, token, _} <- Mailstub.Auth.Guardian.encode_and_sign(user, %{}, token_type: "access") do

      conn
      |> put_resp_header("location", "/")
      |> render(MailstubWeb.Api.UsersView, "show.json", user: user, token: token)
    end
  end

  def delete(conn, _params) do

  end
end
