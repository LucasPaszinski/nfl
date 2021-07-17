defmodule NflWeb.RushesLive do
  use NflWeb, :live_view

  alias NflWeb.Live.Components.{TouchdownIcon, Sorter, Pagination}

  @query_keys ~w(ord sort page player page_size)a

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> from_query_to_socket(params)
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
      |> from_query_to_socket(params)
      |> load_rushes()

    {:noreply, socket}
  end

  @impl true
  def handle_event("sort", %{"sort" => sort, "ord" => ord}, socket) do
    socket =
      socket
      |> assign(sort: sort)
      |> assign(ord: ord)
      |> from_socket_to_query()

    {:noreply, socket}
  end

  @impl true
  def handle_event("page-size", %{"page-size" => page_size}, socket) do
    socket =
      socket
      |> assign(page_size: page_size)
      |> from_socket_to_query()

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
      |> from_socket_to_query()

    {:noreply, socket}
  end

  @impl true
  def handle_event("nav", %{"page" => page} = attrs, socket) do
    socket =
      socket
      |> assign(page: page)
      |> from_socket_to_query()

    {:noreply, socket}
  end

  defp from_socket_to_query(socket) do
    query_params = create_query_params(socket)

    push_patch(socket, to: Routes.rushes_path(socket, :index, query_params))
  end

  defp create_query_params(socket) do
    update_if_exists_in_socket = &update_if_exists(&1, socket.assigns, &2)

    Enum.reduce(@query_keys, %{}, fn key, acc ->
      update_if_exists_in_socket.(acc, key) |> IO.inspect(label: :query_mid)
    end)
    |> IO.inspect(label: :query_params)
  end

  defp update_if_exists(map, assigns, key) do
    case Map.get(assigns, key) do
      "" -> map
      nil -> map
      value -> Map.put(map, key, value)
    end
  end

  defp load_rushes(socket = %{assigns: assigns}) do
    pages = [page: Map.get(assigns, :page, "1"), page_size: Map.get(assigns, :page_size, "10")]
    filters = [player: Map.get(assigns, :player, "")]
    sorts = [{Map.get(assigns, :ord, ""), Map.get(assigns, :sort, "")}]

    %{
      entries: entries,
      page_number: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Nfl.Rushes.Index.paginated_rushes(pages, sorts, filters)

    assign(socket,
      rushes: entries,
      page: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    )
  end

  defp from_query_to_socket(socket, query) do
    get_query_value = &get_from_query_or_socket(query, Atom.to_string(&1), socket, &1)

    assign(socket, Enum.map(@query_keys, &{&1, get_query_value.(&1)}))
  end

  defp get_from_query_or_socket(
         query,
         query_key,
         _socket = %{assigns: assigns},
         assign_key
       ) do
    query_value = Map.get(query, query_key)
    assigns_value = Map.get(assigns, assign_key)

    query_value || assigns_value
  end
end
