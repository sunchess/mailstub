defmodule MailstubWeb.Router do
  use MailstubWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", MailstubWeb.Api do
    pipe_through :api

    resources "/users", UsersController, only: [:index, :create]
  end

  scope "/", MailstubWeb do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end

end
