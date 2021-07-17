defmodule Nfl.Rushes.Index do
  alias Nfl.Repo
  alias Nfl.Schemas.Rush
  alias Nfl.Cache
  import Ecto.Query

  def rushes(sorters \\ [], filters \\ []) do
    from(r in Rush)
    |> join(:inner, [r], p in assoc(r, :player), as: :player)
    |> join(:inner, [player: p], t in assoc(p, :team))
    |> preload([r], player: :team)
    |> sort(sorters)
    |> filter(filters)
  end

  def rushes_all(sorters \\ [], filters \\ []) do
    sorters
    |> rushes(filters)
    |> repo_all_cache()
  end

  def paginated_rushes(paginate_params \\ [], sorters \\ [], filters \\ []) do
    IO.inspect(paginate_params: paginate_params, sorters: sorters, filters: filters)

    sorters
    |> rushes(filters)
    |> IO.inspect()
    |> Repo.paginate(paginate_params)
  end

  def repo_all_cache(query, paginate_params \\ []) do
    key = query_hash(query)

    case Cache.read(__MODULE__, key) do
      {:ok, value} ->
        value

      {:error, _} ->
        value = Repo.paginate(query, paginate_params)
        IO.puts("Loaded from cache")
        Cache.write(__MODULE__, key, value)
    end
  end

  defp query_hash(query) do
    :crypto.hash(:md5, "#{inspect(query)}") |> Base.encode16()
  end

  @sorteble ~w(longest_rush total_rushing_touchdowns total_rushing_yards)
  @orderble ~w(desc asc)

  defp sort(query, [{ord, sort} | rest]) do
    case {sort, ord} |> IO.inspect() do
      {sort, ord} when sort in @sorteble and ord in @orderble ->
        sort = [{String.to_atom(ord), String.to_atom(sort)}] |> IO.inspect()

        query
        |> order_by([r], ^sort)
        |> sort(rest)

      _otherwise ->
        query
    end
  end

  defp sort(query, _) do
    query
  end

  @filterble ~w(player)a

  defp filter(query, [{filter, value} | rest]) do
    case filter do
      filter when filter in @filterble ->
        query
        |> apply_filter(filter, value)
        |> filter(rest)

      _otherwise ->
        query
    end
  end

  defp filter(query, _) do
    query
  end

  defp apply_filter(query, :player, ""), do: query

  defp apply_filter(query, :player, value) do
    where(query, [player: p], ilike(p.name, ^"%#{value}%"))
  end
end
