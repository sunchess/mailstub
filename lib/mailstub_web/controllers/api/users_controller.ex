defmodule MailstubWeb.Api.UsersController do
  use MailstubWeb, :controller

  alias Mailstub.Accounts

  def index(conn, _params) do
    json(conn, %{
      test: "test"
    })
  end

  def create(conn, params) do
    result = case Accounts.create_user(params) do
      {:ok, user} ->
        #{:ok, token, _claims} = Guardian.encode_and_sign(facility, :access)
        {:ok, token, _} = Mailstub.Guardian.encode_and_sign(user)
        %{user: user, token: token}
      {:error, model} -> %{error: model.errors}
    end

    IO.inspect(result)
    json(conn, result)
  end
end
