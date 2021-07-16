defmodule Nfl.CSV do
  alias Nfl.Cache

  def save_as_csv_content(rushes, recover_key) do
    csv_content =
      rushes
      |> parse_content()
      |> CSV.encode()
      |> Enum.join("")

    Cache.write(__MODULE__, recover_key, csv_content)
  end

  def read_csv(recover_key) do
    Cache.read(__MODULE__, recover_key)
  end

  @headers [
    "Player Name",
    "Team",
    "Position",
    "Rushing Attempts Per Game Average",
    "Rushing Attempts",
    "Total Rushing Yards",
    "Rushing Average Yards Per Attempt",
    "Rushing Yards Per Game",
    "Total Rushing Touchdowns",
    "Longest Rush",
    "Rushing First Downs",
    "Rushing First Down Percentage",
    "Rushing 20+ Yards Each",
    "Rushing 40+ Yards Each",
    "Rushing Fumbles"
  ]

  defp parse_content(rushes) do
    [@headers | Enum.map(rushes, &rushes_to_line(&1))]
  end

  defp rushes_to_line(%Nfl.Schemas.Rush{} = rush) do
    [
      rush.player.name,
      rush.player.team.name,
      rush.player.position,
      rush.rushing_attemps_per_game_average,
      rush.rushing_attemps,
      rush.total_rushing_yards,
      rush.rushing_average_yards_per_attempt,
      rush.rushing_yards_per_game,
      rush.total_rushing_touchdowns,
      "#{rush.longest_rush}#{if rush.is_touchdown, do: "T", else: ""}",
      rush.rushing_first_downs,
      rush.rushing_first_downs_per_cent,
      rush.rushing_20_plus_yards_each,
      rush.rushing_40_plus_yards_each,
      rush.rushing_fumbles
    ]
  end
end
