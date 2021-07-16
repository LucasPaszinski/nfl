defmodule Nfl.Rushes.Index do
  alias Nfl.Repo
  alias Nfl.Schemas.Rush
  import Ecto.Query

  def rushes(sorters \\ [], filters \\ []) do
    from(r in Rush)
    |> join(:inner, [r], p in assoc(r, :player), as: :player)
    |> join(:inner, [player: p], t in assoc(p, :team))
    |> preload([r], player: :team)
    |> sort_by(sorters)
    |> filter_by(filters)
    |> Repo.all()
  end

  @sorteble_by ~w(longest_rush total_rushing_touchdowns total_rushing_yards)

  defp sort_by(query, [%{"sort_by" => sort_by} | rest]) do
    case sort_by do
      sort_by when sort_by in @sorteble_by ->
        sort_by = [String.to_atom(sort_by)]

        query
        |> order_by([r], ^sort_by)
        |> sort_by(rest)

      _otherwise ->
        query
    end
  end

  defp sort_by(query, _) do
    query
  end

  @filterble_by ~w(player_name)

  defp filter_by(query, [%{"filter_by" => filter_by, "filter_value" => value} | rest]) do
    case filter_by do
      filter_by when filter_by in @filterble_by ->
        filter_by = String.to_atom(filter_by)

        query
        |> apply_filter(filter_by, value)
        |> filter_by(rest)

      _otherwise ->
        query
    end
  end

  defp filter_by(query, _) do
    query
  end

  defp apply_filter(query, :player_name, value) do
    query
    |> where([player: p], ilike(p.name, ^"%#{value}%"))
  end
end
