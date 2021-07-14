defmodule Nfl.Repo.Migrations.CreateRush do
  use Ecto.Migration

  def change do
    create table(:rushes) do
      # References Player Info
      add :player_id, references(:players)


      # Att/G (Rushing Attempts Per Game Average)
      add :rushing_attemps_per_game_average, :decimal
      # Att (Rushing Attempts)
      add :rushing_attemps, :integer
      # Yds (Total Rushing Yards)
      add :total_rushing_yards, :integer
      # Avg (Rushing Average Yards Per Attempt)
      add :rushing_average_yards_per_attempt, :decimal
      # Yds/G (Rushing Yards Per Game)
      add :rushing_yards_per_game, :decimal
      # TD (Total Rushing Touchdowns)
      add :total_rushing_touchdowns, :integer
      # Lng (Longest Rush -- a T represents a touchdown occurred)
      add :is_touchdown, :boolean
      add :longest_rush, :integer
      # 1st (Rushing First Downs)
      add :rushing_first_downs, :integer
      # 1st% (Rushing First Down Percentage)
      add :rushing_first_downs_per_cent, :decimal
      # 20+ (Rushing 20+ Yards Each)
      add :rushing_20_plus_yards_each, :integer
      # 40+ (Rushing 40+ Yards Each)
      add :rushing_40_plus_yards_each, :integer
      # FUM (Rushing Fumbles)
      add :rushing_fumbles, :integer

      timestamps()
    end
  end
end
