defmodule Nfl.Repo do
  use Ecto.Repo,
    otp_app: :nfl,
    adapter: Ecto.Adapters.Postgres
end
