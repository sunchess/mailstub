defmodule MailstubWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use MailstubWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(MailstubWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(MailstubWeb.ErrorView, :"404")
  end

  def call(conn, {:error, :password_is_invalid}) do
    conn
    |> put_status(:not_found)
    |> render(MailstubWeb.ErrorView, "error.json", status: :unauthorized,  message: "Password is invalid")
  end

  def call(conn, {:error, :user_is_not_found}) do
    conn
    |> put_status(:not_found)
    |> render(MailstubWeb.ErrorView, "error.json", status: :unauthorized,  message: "Email is not found")
  end
end
