defmodule Nfl.Rushes.Index do
  import Ecto.Query

  alias Nfl.Repo
  alias Nfl.Schemas.Rush
  alias Nfl.Cache

  def rushes_query(sorters \\ [], filters \\ []) do
    from(r in Rush)
    |> join(:inner, [r], p in assoc(r, :player), as: :player)
    |> join(:inner, [player: p], t in assoc(p, :team))
    |> preload([r], player: :team)
    |> sort(sorters)
    |> filter(filters)
    |> order_by([player: p], asc: p.name)
  end

  def rushes_all(sorters \\ [], filters \\ []) do
    sorters
    |> rushes_query(filters)
    |> Repo.all()
  end

  def rushes_paginated(paginate \\ [], sorters \\ [], filters \\ []) do
    sorters
    |> rushes_query(filters)
    |> Repo.paginate(paginate)
  end

  @sorteble ~w(longest_rush total_rushing_touchdowns total_rushing_yards)
  @orderble ~w(desc asc)

  defp sort(query, [{ord, sort} | rest]) when sort in @sorteble and ord in @orderble do
    sort = [{String.to_atom(ord), String.to_atom(sort)}]

    query
    |> order_by([r], ^sort)
    |> sort(rest)
  end

  defp sort(query, _) do
    query
  end

  @filterble ~w(player)a

  defp filter(query, [{filter, value} | rest]) when filter in @filterble do
    query
    |> apply_filter(filter, value)
    |> filter(rest)
  end

  defp filter(query, _) do
    query
  end

  defp apply_filter(query, :player, ""), do: query

  defp apply_filter(query, :player, value) do
    where(query, [player: p], ilike(p.name, ^"%#{value}%"))
  end
end
