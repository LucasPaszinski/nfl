defmodule Nfl.Schemas.Player do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Nfl.Schemas.Team

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields [:name, :team_id]

  @type t :: %__MODULE__{
          team: Team.t() | Ecto.Association.NotLoaded.t(),
          name: String.t(),
          position: String.t()
        }

  schema "players" do
    belongs_to :team, Team

    field :name, :string
    field :position, :string

    timestamps()
  end

  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = player, attrs) do
    player
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
