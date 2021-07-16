defmodule NflWeb.DownloadCsvController do
  use NflWeb, :controller

  def download(conn, %{"recover_key" => key}) do
    {:ok, content} = Nfl.CSV.read_csv(key)

    content |> IO.inspect()

    conn
    |> send_download({:binary, content}, filename: "rushes_table.csv")
    |> halt()
  end
end
