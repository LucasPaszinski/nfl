defmodule NflWeb.RushesLive do
  use NflWeb, :live_view

  alias NflWeb.Live.Components.{TouchdownIcon, Sorter, Pagination, PageSize}

  @query_params_and_defaults [ord: "", sort: "", page: 1, player: "", page_size: 10]
  @hide_values_from_query ["", nil]

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> load_from_query_to_socket(params)
      |> load_rushes()

    {:ok, socket}
  end

  @impl true
  def handle_params(
        params,
        _uri,
        socket
      ) do
    socket =
      socket
      |> load_from_query_to_socket(params)
      |> load_rushes()

    {:noreply, socket}
  end

  @impl true
  def handle_event("sort", %{"sort" => sort, "ord" => ord}, socket) do
    socket =
      socket
      |> assign(sort: sort, ord: ord)
      |> load_from_socket_to_query()

    {:noreply, socket}
  end

  @impl true
  def handle_event("row", %{"row" => page_size}, socket) do
    socket =
      socket
      |> assign(page_size: page_size, page: 1)
      |> load_from_socket_to_query()

    {:noreply, socket}
  end

  @impl true
  def handle_event("download", _, socket) do
    params = create_query_params(socket)
    socket = redirect(socket, to: Routes.download_csv_path(socket, :download, params))

    {:noreply, socket}
  end

  @impl true
  def handle_event("player", %{"value" => player}, socket) do
    socket =
      socket
      |> assign(player: player)
      |> assign(page: 1)
      |> load_from_socket_to_query()

    {:noreply, socket}
  end

  @impl true
  def handle_event("nav", %{"page" => page}, socket) do
    socket =
      socket
      |> assign(page: page)
      |> load_from_socket_to_query()

    {:noreply, socket}
  end

  defp load_from_query_to_socket(socket, query) do
    get_query_value = fn {key, _default_value} ->
      value = get_from_query_or_socket(query, Atom.to_string(key), socket, key)

      {key, value}
    end

    assign(socket, Enum.map(@query_params_and_defaults, &get_query_value.(&1)))
  end

  defp load_from_socket_to_query(socket) do
    query_params = create_query_params(socket, true)

    push_patch(socket, to: Routes.rushes_path(socket, :index, query_params))
  end

  defp get_from_query_or_socket(
         query,
         query_key,
         %{assigns: assigns} = _socket,
         assign_key
       ) do
    query_value = Map.get(query, query_key)
    assigns_value = Map.get(assigns, assign_key)

    query_value || assigns_value
  end

  defp create_query_params(%{assigns: assigns} = _socket, hide_values_from_query? \\ false) do
    Enum.reduce(@query_params_and_defaults, %{}, fn {key, default_val}, acc ->
      value = Map.get(assigns, key) || default_val

      case value do
        value when hide_values_from_query? and value in @hide_values_from_query ->
          acc

        value ->
          Map.put(acc, key, value)
      end
    end)
  end

  defp create_filter_params(%{player: ""}), do: []
  defp create_filter_params(%{player: player}), do: [player: player]

  defp create_sort_params(%{sort: ""}), do: []
  defp create_sort_params(%{ord: ""}), do: []
  defp create_sort_params(%{ord: ord, sort: sort}), do: [{ord, sort}]

  defp create_page_params(%{page: page, page_size: page_size}) do
    [page: page, page_size: page_size]
  end

  defp load_rushes(socket) do
    query_params = create_query_params(socket)

    pages = create_page_params(query_params)
    sorts = create_sort_params(query_params)
    filters = create_filter_params(query_params)

    {time, rushes_page} =
      :timer.tc(fn -> Nfl.Rushes.Index.rushes_paginated(pages, sorts, filters) end)

    IO.puts("Took #{time / 1000}ms")

    assign(socket,
      entries: rushes_page.entries,
      page: rushes_page.page_number,
      page_size: rushes_page.page_size,
      total_entries: rushes_page.total_entries,
      total_pages: rushes_page.total_pages
    )
  end
end
