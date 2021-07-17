defmodule Nfl.Repo do
  use Ecto.Repo,
    otp_app: :nfl,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
