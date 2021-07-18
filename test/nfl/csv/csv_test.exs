defmodule Nfl.CSVTest do
  use Nfl.DataCase, async: true

  describe "generate_csv_content" do
    setup do
      rushes = insert_list(3, :rush)

      {:ok, rushes: rushes}
    end

    test "passing no data" do
      assert Nfl.CSV.generate_csv_content([]) =~
               "Player,Team,Position,Rushing Attempts Per Game Average," <>
                 "Rushing Attempts,Total Rushing Yards,Rushing Average Yards Per Attempt," <>
                 "Rushing Yards Per Game,Total Rushing Touchdowns,Longest Rush," <>
                 "Rushing First Downs,Rushing First Down Percentage," <>
                 "Rushing 20+ Yards Each,Rushing 40+ Yards Each,Rushing Fumbles\r\n"
    end

    test "passing when passing a rushes check if order of rows is keept", %{rushes: rushes} do
      csv_content = Nfl.CSV.generate_csv_content(rushes)

      assert csv_content =~
               "Player,Team,Position,Rushing Attempts Per Game Average," <>
                 "Rushing Attempts,Total Rushing Yards,Rushing Average Yards Per Attempt," <>
                 "Rushing Yards Per Game,Total Rushing Touchdowns,Longest Rush," <>
                 "Rushing First Downs,Rushing First Down Percentage," <>
                 "Rushing 20+ Yards Each,Rushing 40+ Yards Each,Rushing Fumbles\r\n"

      pattern =
        rushes
        |> Stream.map(& &1.player.name)
        |> Enum.join(".*")
        |> Regex.compile!("s")

      assert Regex.match?(pattern, csv_content)
    end

    defp rush_to_list(rush) do
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
        rush.longest_rush,
        "#{if rush.is_touchdown, do: "T", else: ""}",
        rush.rushing_first_downs,
        rush.rushing_first_downs_per_cent,
        rush.rushing_20_plus_yards_each,
        rush.rushing_40_plus_yards_each,
        rush.rushing_fumbles
      ]
    end

    test "if columns are correcly ordered", %{rushes: rushes} do
      csv_content = Nfl.CSV.generate_csv_content(rushes)

      pattern =
        rushes
        |> Enum.map(&rush_to_list/1)
        |> List.flatten()
        |> Enum.join(".*")
        |> Regex.compile!("s")

      Regex.match?(pattern, csv_content)
    end

    for key <- ~w(rushing_attemps_per_game_average rushing_attemps total_rushing_yards
    rushing_average_yards_per_attempt rushing_yards_per_game total_rushing_touchdowns
    rushing_first_downs rushing_first_downs_per_cent rushing_20_plus_yards_each
    rushing_40_plus_yards_each rushing_fumbles)a do
      @tag key: key
      test "test if #{key} contents appear", %{key: key, rushes: rushes} do
        pattern =
          rushes |> Stream.map(&Map.get(&1, key)) |> Enum.join(".*") |> Regex.compile!("s")

        csv_content = Nfl.CSV.generate_csv_content(rushes)

        assert Regex.match?(pattern, csv_content)
      end
    end
  end
end
