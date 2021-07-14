defmodule Nfl.Schemas.Rush do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Nfl.Schemas.Player

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields [
    :rushing_attemps_per_game_average,
    :rushing_attemps,
    :total_rushing_yards,
    :rushing_average_yards_per_attempt,
    :rushing_yards_per_game,
    :total_rushing_touchdowns,
    :is_touchdown,
    :longest_rush,
    :rushing_first_downs,
    :rushing_first_downs_per_cent,
    :rushing_20_plus_yards_each,
    :rushing_40_plus_yards_each,
    :rushing_fumbles,
    :player_id
  ]

  @type t :: %__MODULE__{
          player: Player.t() | Ecto.Association.NotLoaded.t(),
          rushing_attemps_per_game_average: Decimal.t(),
          rushing_attemps: integer(),
          total_rushing_yards: integer(),
          rushing_average_yards_per_attempt: Decimal.t(),
          rushing_yards_per_game: Decimal.t(),
          total_rushing_touchdowns: integer(),
          is_touchdown: boolean(),
          longest_rush: integer(),
          rushing_first_downs: integer(),
          rushing_first_downs_per_cent: Decimal.t(),
          rushing_20_plus_yards_each: integer(),
          rushing_40_plus_yards_each: integer(),
          rushing_fumbles: integer()
        }

  schema "rushes" do
    belongs_to :player, Player

    field :rushing_attemps_per_game_average, :decimal
    field :rushing_attemps, :integer
    field :total_rushing_yards, :integer
    field :rushing_average_yards_per_attempt, :decimal
    field :rushing_yards_per_game, :decimal
    field :total_rushing_touchdowns, :integer
    field :is_touchdown, :boolean
    field :longest_rush, :integer
    field :rushing_first_downs, :integer
    field :rushing_first_downs_per_cent, :decimal
    field :rushing_20_plus_yards_each, :integer
    field :rushing_40_plus_yards_each, :integer
    field :rushing_fumbles, :integer

    timestamps()
  end

  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = rush, attrs) do
    rush
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
