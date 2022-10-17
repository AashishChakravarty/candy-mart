defmodule CandyMart.Repo do
  use Ecto.Repo,
    otp_app: :candy_mart,
    adapter: Ecto.Adapters.Postgres
end
