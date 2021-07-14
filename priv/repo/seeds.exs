# mix run priv/repo/seeds.exs

alias Nfl.Repo
alias Nfl.Schemas.{Team, Rush, Player}

# Helper Functions
create_team = fn team_name ->
  %Team{} |> Team.changeset(%{name: team_name}) |> Repo.insert!()
end

create_player = fn player_info, team_id ->
  %{"Player" => name, "Pos" => position} = player_info

  %Player{}
  |> Player.changeset(%{team_id: team_id, name: name, position: position})
  |> Repo.insert!()
end

create_rush = fn rush_info, player_id ->
  %{
    "Att/G" => rushing_attemps_per_game_average,
    "Att" => rushing_attemps,
    "Yds" => total_rushing_yards,
    "Avg" => rushing_average_yards_per_attempt,
    "Yds/G" => rushing_yards_per_game,
    "TD" => total_rushing_touchdowns,
    "Lng" => longest_rush,
    "1st" => rushing_first_downs,
    "1st%" => rushing_first_downs_per_cent,
    "20+" => rushing_20_plus_yards_each,
    "40+" => rushing_40_plus_yards_each,
    "FUM" => rushing_fumbles
  } = rush_info

  convert_to_integer = fn
    value when is_integer(value) ->
      value

    value when is_binary(value) ->
      value
      |> String.replace(~r/[^0-9]/, "")
      |> String.to_integer()
  end

  is_touchdown = fn
    longest_rush when is_integer(longest_rush) ->
      false

    longest_rush when is_binary(longest_rush) ->
      longest_rush
      |> String.contains?("T")
  end

  attrs = %{
    player_id: player_id,
    rushing_attemps_per_game_average: rushing_attemps_per_game_average,
    rushing_attemps: rushing_attemps,
    total_rushing_yards: convert_to_integer.(total_rushing_yards),
    rushing_average_yards_per_attempt: rushing_average_yards_per_attempt,
    rushing_yards_per_game: rushing_yards_per_game,
    total_rushing_touchdowns: total_rushing_touchdowns,
    longest_rush: convert_to_integer.(longest_rush),
    is_touchdown: is_touchdown.(longest_rush),
    rushing_first_downs: rushing_first_downs,
    rushing_first_downs_per_cent: rushing_first_downs_per_cent,
    rushing_20_plus_yards_each: rushing_20_plus_yards_each,
    rushing_40_plus_yards_each: rushing_40_plus_yards_each,
    rushing_fumbles: rushing_fumbles
  }

  %Rush{}
  |> Rush.changeset(attrs)
  |> Repo.insert!()
end

# Populate Database with data from .json
Repo.transaction(fn ->
  # Load json to create database
  System.cwd!()
  |> Path.join("priv/files/rushing.json")
  |> File.read!()
  |> Jason.decode!()
  |> IO.inspect()
  |> Enum.group_by(& &1["Team"])
  |> Map.to_list()
  |> Enum.map(fn {team_name, infos} ->
    team = create_team.(team_name)

    Enum.map(infos, fn info ->
      player = create_player.(info, team.id)
      rush = create_rush.(info, player.id)
    end)
  end)
end)
