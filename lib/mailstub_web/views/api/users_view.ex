defmodule MailstubWeb.Api.UsersView do
  use MailstubWeb, :view
  alias MailstubWeb.Api.UsersView

  def render("show.json", %{user: user, token: token}) do
    %{id: user.id, email: user.email, token: token}
  end

  def render("index.json", %{user: user}) do
    %{data: render_many(user, UsersView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UsersView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email}
  end
end
