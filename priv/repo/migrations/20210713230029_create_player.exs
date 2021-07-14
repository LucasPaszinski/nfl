defmodule Nfl.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      # Team (Player's team abbreviation)
      add :team_id, references(:teams)


      # Player (Player's name)
      add :name, :string
      # Pos (Player's postion)
      add :position, :string

      timestamps()
    end

    create unique_index(:players, [:name])
  end
end
