# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mailstub,
  ecto_repos: [Mailstub.Repo]

# Configures the endpoint
config :mailstub, MailstubWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2subNscCJKh31hREEz1HM1rvwJKK482Xc1lEMilyDN5axrP4DWIFDGs8d38omkca",
  render_errors: [view: MailstubWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mailstub.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :mailstub, Mailstub.Guardian,
       issuer: "mailstub",
       secret_key: "vQ4e2Rges/IOE8L6vbAZK7KkfGB4uP3kgxFHpS4AYFIy+6Z0tkNU6mZc/eg3fquz"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# This is where you want the JSON of the mail to be posted to
#config :mail_to_json, :webhook_url, System.get_env("M2J_WEBHOOK_URL")

# The SMTP port to which we want our application to listen to
config :mailstub, MailToJson,
  smtp_port: 1025

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
