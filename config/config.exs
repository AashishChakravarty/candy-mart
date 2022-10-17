# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :candy_mart,
  ecto_repos: [CandyMart.Repo]

# Configures the endpoint
config :candy_mart, CandyMartWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Gfdvg1b+seZMSNQGvRFFvNpBYt2CAzBStVkmtqw4vbTqwmuIpxMjzcTKXYCPfblt",
  render_errors: [view: CandyMartWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CandyMart.PubSub,
  live_view: [signing_salt: "f8QNqAF1"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :candy_mart, :pow,
  user: CandyMart.Users.User,
  repo: CandyMart.Repo

config :torch,
  otp_app: :my_app_name,
  template_format: "eex"

config :money,
  default_currency: :USD

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
