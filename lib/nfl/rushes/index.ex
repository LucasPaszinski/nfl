defmodule Nfl.Rushes.Index do
  @moduledoc """
  Index (Get all) the records of rushes from database, also allow filters and sorts.
  """
  import Ecto.Query

  alias Nfl.Repo
  alias Nfl.Schemas.Rush
  alias Scrivener.Page
  alias Nfl.Cache

  @type sorters() :: list({String.t(), String.t()})
  @type filters() :: list({atom(), String.t()})
  @type paginate() :: list({atom(), String.t() | integer()})
  @type rush_list() :: list(Rush.t())
  @type rush_page() :: Page.t(Rush.t())
  @type generic_repo() :: (Ecto.Query.t() -> rush_list() | rush_page())

  @spec rushes_query(sorters(), filters()) :: Ecto.Query.t()
  defp rushes_query(sorters, filters) do
    from(r in Rush)
    |> join(:inner, [r], p in assoc(r, :player), as: :player)
    |> join(:inner, [player: p], t in assoc(p, :team))
    |> preload([r], player: :team)
    |> sort(sorters)
    |> filter(filters)
    |> order_by([player: p], asc: p.name)
  end

  @doc """
  Build a query with sorts and filter arguments, return the Rushes matching the criteria.
  """
  @spec rushes_all(sorters(), filters()) :: rush_list()
  def rushes_all(sorters \\ [], filters \\ []) do
    rushes(sorters, filters, &Repo.all/1)
  end

  @doc """
  Build a query with sorts and filter arguments, return the Rushes matching the criteria, but paginated.
  """
  @spec rushes_paginated(paginate(), sorters(), filters()) :: rush_page()
  def rushes_paginated(paginate \\ [], sorters \\ [], filters \\ []) do
    rushes(paginate, sorters, filters, &Repo.paginate(&1, paginate))
  end

  @spec rushes(paginate(), sorters(), filters(), generic_repo()) :: rush_list() | rush_page()
  defp rushes(paginate \\ [], sorters, filters, repo) do
    key = create_query_key(paginate, sorters, filters)
    query_builder = fn -> rushes_query(sorters, filters) end

    repo_or_cache(key, query_builder, repo)
  end

  @spec repo_or_cache(String.t(), (() -> Ecto.Query.t()), generic_repo()) ::
          rush_list() | rush_page()
  defp repo_or_cache(key, query_builder, repo) do
    case Cache.read(__MODULE__, key) do
      {:ok, value} ->
        value

      {:error, _} ->
        value = query_builder.() |> repo.()

        Cache.write(__MODULE__, key, value)
    end
  end

  @sorteble ~w(longest_rush total_rushing_touchdowns total_rushing_yards)
  @orderble ~w(desc asc)

  @spec sort(Ecto.Query.t(), sorters()) :: Ecto.Query.t()
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

  @spec filter(Ecto.Query.t(), filters()) :: Ecto.Query.t()
  defp filter(query, [{filter, value} | rest]) when filter in @filterble do
    query
    |> apply_filter(filter, value)
    |> filter(rest)
  end

  defp filter(query, _) do
    query
  end

  @spec apply_filter(Ecto.Query.t(), atom(), String.t()) :: Ecto.Query.t()
  defp apply_filter(query, :player, ""), do: query

  defp apply_filter(query, :player, value) do
    where(query, [player: p], ilike(p.name, ^"%#{value}%"))
  end

  @spec create_query_key(paginate(), sorters(), filters()) :: String.t()
  defp create_query_key(paginate, sorters, filters) do
    [paginate, sorters, filters]
    |> List.flatten()
    |> Stream.map(fn {k, v} -> {to_string(k), to_string(v)} end)
    |> Stream.map(fn {k, v} -> k <> v end)
    |> Enum.sort()
    |> Enum.join()
    |> Cache.create_key()
  end
end
