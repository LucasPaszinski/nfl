defmodule NflWeb.RushesLive do
  use NflWeb, :live_view

  alias NflWeb.Live.Components.{TouchdownIcon, Sorter}

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> update_filter_and_sort(params)
      |> update_rushes()

    {:ok, socket}
  end

  def handle_event("download", _, socket) do
    rushes =
      socket.assigns.rushes
      |> Nfl.CSV.save_as_csv_content(socket.id)

    socket =
      redirect(socket,
        to: Routes.download_csv_path(socket, :download, %{"recover_key" => socket.id})
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("player_filter", %{"value" => value} = attrs, socket) do
    socket =
      socket
      |> assign(filter_by: "player_name", filter_value: value)
      |> Phoenix.LiveView.push_patch(
        to:
          Routes.rushes_path(socket, :index, %{
            filter_by: "player_name",
            filter_value: value,
            sort_by: socket.assigns.sort_by,
            order_by: socket.assigns.order_by
          })
      )
      |> update_rushes()

    {:noreply, socket}
  end

  def handle_params(
        params,
        _uri,
        socket
      ) do

    socket =
      socket
      |> update_filter_and_sort(params)
      |> update_rushes()

    {:noreply, socket}
  end

  defp update_rushes(socket) do
    filters = [
      %{
        "filter_by" => socket.assigns.filter_by,
        "filter_value" => socket.assigns.filter_value
      }
    ]

    sorts = [
      %{"sort_by" => socket.assigns.sort_by, "order_by" => socket.assigns.order_by}
    ]

    {time, rushes} = :timer.tc(fn -> Nfl.Rushes.Index.rushes(sorts, filters) end)

    IO.puts("Loading took #{time}")

    rushes = assign(socket, rushes: rushes)
  end

  defp update_filter_and_sort(socket, params) do
    filter_value = Map.get(params, "filter_value", "")
    filter_by = Map.get(params, "filter_by", "")
    sort_by = Map.get(params, "sort_by", "")
    order_by = Map.get(params, "order_by", "")

    assign(socket,
      filter_value: filter_value,
      sort_by: sort_by,
      order_by: order_by,
      filter_by: filter_by
    )
  end
end
