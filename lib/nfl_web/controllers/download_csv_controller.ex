defmodule NflWeb.DownloadCsvController do
  use NflWeb, :controller

  def download(conn, params) do
    filters = create_filters(params)
    sorts = create_sort(params)

    content =
      sorts
      |> Nfl.Rushes.Index.rushes_all(filters)
      |> Nfl.CSV.generate_csv_content()

    conn
    |> send_download({:binary, content}, filename: "rushes_table.csv")
    |> halt()
  end

  defp create_filters(%{"player" => player}), do: [player: player]
  defp create_filters(_), do: []

  defp create_sort(%{"ord" => ord, "sort" => sort}), do: [{ord, sort}]
  defp create_sort(_), do: []
end
