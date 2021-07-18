defmodule Nfl.Factory do
  use ExMachina.Ecto, repo: Nfl.Repo

  alias Nfl.Schemas.{Rush, Player, Team}

  @team_names ~w(ARI ATL BAL BUF CAR CHI CIN CLE DAL DEN DET GB HOU IND JAX KC LA MIA MIN NE NO NYG NYJ OAK PHI PIT SD SEA SF TB TEN WAS)
  @player_position ~w(WR QB RB P FB SS K TE NT DB)

  def team_factory do
    %Team{
      name: sequence(:name, @team_names)
    }
  end

  def player_factory do
    %Player{
      name: Faker.Person.name(),
      position: sequence(:position, @player_position),
      team: build(:team)
    }
  end

  def rush_factory do
    %Rush{
      is_touchdown: sequence(:is_touchdown, [true, false]),
      longest_rush: Enum.random(-8..85),
      rushing_20_plus_yards_each: Enum.random(0..14),
      rushing_40_plus_yards_each: Enum.random(0..4),
      rushing_attemps: Enum.random(1..322),
      rushing_attemps_per_game_average: Decimal.new("#{Enum.random(0..21)}.#{Enum.random(0..9)}"),
      rushing_average_yards_per_attempt:
        Decimal.new("#{Enum.random(0..21)}.#{Enum.random(0..9)}"),
      rushing_first_downs: Enum.random(0..91),
      rushing_first_downs_per_cent: Decimal.new("#{Enum.random(0..66)}.#{Enum.random(0..9)}"),
      rushing_fumbles: Enum.random(0..7),
      rushing_yards_per_game: Decimal.new("#{Enum.random(0..108)}.#{Enum.random(0..9)}"),
      total_rushing_touchdowns: Enum.random(0..18),
      total_rushing_yards: Enum.random(-23..1631),
      player: build(:player)
    }
  end
end
