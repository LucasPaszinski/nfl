defmodule NflWeb.DownloadCsvController do
  use NflWeb, :controller

  def download(conn, %{"ord" => ord, "player" => player, "sort" => sort}) do
    filters = [player: player]
    sorts = [{ord, sort}]

    content =
      sorts
      |> Nfl.Rushes.Index.rushes_all(filters)
      |> Nfl.CSV.generate_csv_content()

    conn
    |> send_download({:binary, content}, filename: "rushes_table.csv")
    |> halt()
  end
end
