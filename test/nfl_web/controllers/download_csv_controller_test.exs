defmodule NflWeb.DownloadCsvControllerTest do
  use NflWeb.ConnCase

  @header "Player,Team,Position,Rushing Attempts Per Game Average," <>
            "Rushing Attempts,Total Rushing Yards,Rushing Average Yards Per Attempt," <>
            "Rushing Yards Per Game,Total Rushing Touchdowns,Longest Rush," <>
            "Rushing First Downs,Rushing First Down Percentage,Rushing 20+ Yards Each," <>
            "Rushing 40+ Yards Each,Rushing Fumbles\r\n"

  describe "download/2 no data" do
    test "return only the headers", %{conn: conn} do
      path = Routes.download_csv_path(conn, :download)

      conn = get(conn, path)

      assert response(conn, 200) =~ @header
    end
  end

  describe "download/2 with data" do
    setup do
      player_1 = insert(:player, name: "Aaron Shawn")
      player_2 = insert(:player, name: "ZZion J3")

      rushes = [
        insert(:rush,
          player: player_1,
          longest_rush: 1,
          total_rushing_touchdowns: 1,
          total_rushing_yards: 1
        ),
        insert(:rush,
          player: player_2,
          longest_rush: 999,
          total_rushing_touchdowns: 999,
          total_rushing_yards: 999
        )
      ]

      {:ok, rushes: rushes}
    end

    test "no filter returns order alfabetically", %{conn: conn, rushes: rushes} do
      path = Routes.download_csv_path(conn, :download)

      conn = get(conn, path)

      response = response(conn, 200)

      assert response =~ @header

      pattern =
        rushes
        |> Enum.map(& &1.player.name)
        |> Enum.join(".*")
        |> Regex.compile!("s")

      assert Regex.match?(pattern, response)
    end

    for sort <- ~w(longest_rush total_rushing_touchdowns total_rushing_yards)a do
      for ord <- ~w(asc desc)a do
        @tag sort: sort
        @tag ord: ord

        test "with sort #{sort} and ord #{ord}", %{
          conn: conn,
          ord: ord,
          sort: sort,
          rushes: rushes
        } do
          attrs = %{"ord" => ord, "sort" => sort}

          path = Routes.download_csv_path(conn, :download, attrs)

          conn = get(conn, path)

          response = response(conn, 200)

          assert response =~ @header

          pattern =
            rushes
            |> Enum.map(&Map.get(&1, sort))
            |> Enum.sort(ord)
            |> Enum.join(".*")
            |> Regex.compile!("s")

          assert Regex.match?(pattern, response)
        end
      end
    end
  end
end
