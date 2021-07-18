defmodule NflWeb.RushLiveTest do
  use NflWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "disconnected and connected render title", %{conn: conn} do
    {:ok, _page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "NFL Rushes"
  end

  @expected_titles [
    "Team",
    "Position",
    "Rushing Attempts Per Game Average",
    "Rushing Attempts",
    "Total Rushing Yards",
    "Rushing Average Yards Per Attempt",
    "Rushing Yards Per Game",
    "Total Rushing Touchdowns",
    "Longest Rush",
    "Rushing First Downs",
    "Rushing First Down Percentage",
    "Rushing 20+ Yards Each",
    "Rushing 40+ Yards Each",
    "Rushing Fumbles"
  ]

  for text <- @expected_titles do
    @tag text: text

    test("disconnected and connected render table headers#{text}", %{conn: conn, text: text}) do
      {:ok, page_live, disconnected_html} = live(conn, "/")
      assert disconnected_html =~ text
      assert render(page_live) =~ text
    end
  end

  describe "check if table render all field" do
    setup do
      {:ok, rush: insert(:rush)}
    end

    @rush_fields ~w(longest_rush rushing_20_plus_yards_each rushing_40_plus_yards_each
    rushing_attemps rushing_attemps_per_game_average rushing_average_yards_per_attempt
    rushing_first_downs rushing_first_downs_per_cent rushing_fumbles rushing_yards_per_game
    total_rushing_touchdowns total_rushing_yards)a

    for rush_field <- @rush_fields do
      @tag field: rush_field
      test "check #{rush_field} is rendered", %{conn: conn, field: field, rush: rush} do
        {:ok, page_live, disconnected_html} = live(conn, "/")

        text = "#{Map.get(rush, field)}"

        assert disconnected_html =~ text
        assert render(page_live) =~ text
      end
    end

    test "check is_touchdown render T", %{conn: conn} do
      %{longest_rush: longest_rush_t} = insert(:rush, is_touchdown: true, longest_rush: 9212)
      %{longest_rush: longest_rush} = insert(:rush, is_touchdown: false, longest_rush: 5798)

      {:ok, page_live, disconnected_html} = live(conn, "/")

      live_page = render(page_live)

      assert disconnected_html =~ "#{longest_rush_t} T"
      assert live_page =~ "#{longest_rush_t} T"
      assert disconnected_html =~ ">#{longest_rush}<"
      assert live_page =~ ">#{longest_rush}<"
    end
  end

  test "when touchdown is clicked should show a flash message", %{conn: conn} do
    insert(:rush, is_touchdown: true, longest_rush: 9212)

    {:ok, page_live, disconnected_html} = live(conn, "/")

    refute disconnected_html =~ "T means the player made a touchdown during longest rush"
    refute render(page_live) =~ "T means the player made a touchdown during longest rush"

    assert page_live
           |> element("div", "9212 T")
           |> render_click() =~ "T is for when a touchdown happens during the longest rush"
  end

  describe "sorting on the table" do
    defp create_text_longest_rush(%{longest_rush: value, is_touchdown: true}),
      do:
        "id=\"longest_rush\".*#{value} T<"

    defp create_text_longest_rush(%{longest_rush: value, is_touchdown: false}),
      do: "id=\"longest_rush\".*#{value}<"

    defp create_text(sort, rush) do
      value = Map.get(rush, sort)

      case sort do
        :longest_rush ->
          create_text_longest_rush(rush)

        _ ->
          "id=\"#{sort}\">#{value}<"
      end
    end

    defp create_regex(rushes, sort) do
      rushes
      |> Stream.map(&create_text(sort, &1))
      |> Enum.join(".*")
      |> Regex.compile!("s")
    end

    defp sorted_regex(%{sort: sort}) do
      rushes = insert_list(3, :rush)

      ordered_name_regex =
        rushes
        |> Enum.sort_by(& &1.player.name)
        |> create_regex(sort)

      value_order = fn ord ->
        rushes
        |> Enum.sort_by(& &1.player.name)
        |> Enum.sort_by(&Map.get(&1, sort), ord)
        |> create_regex(sort)
      end

      ordered_desc_regex = value_order.(:desc)
      ordered_asc_regex = value_order.(:asc)

      {:ok,
       %{
         rushes: rushes,
         ordered_name_regex: ordered_name_regex,
         ordered_desc_regex: ordered_desc_regex,
         ordered_asc_regex: ordered_asc_regex
       }}
    end

    for sort <- ~w(longest_rush total_rushing_touchdowns total_rushing_yards)a do
      @tag sort: sort

      setup [:sorted_regex]

      test "when sorting #{sort} happens, table order should change", %{
        conn: conn,
        sort: sort,
        ordered_name_regex: ordered_name_regex,
        ordered_desc_regex: ordered_desc_regex,
        ordered_asc_regex: ordered_asc_regex
      } do
        {:ok, page_live, disconnected_html} = live(conn, "/")

        assert Regex.match?(ordered_name_regex, disconnected_html)
        assert Regex.match?(ordered_name_regex, render(page_live))

        reordered_live_desc =
          page_live
          |> element("td.#{sort}")
          |> render_click()

        assert Regex.match?(ordered_desc_regex, reordered_live_desc)

        reordered_live_asc =
          page_live
          |> element("td.#{sort}")
          |> render_click()

        assert Regex.match?(ordered_asc_regex, reordered_live_asc)
      end
    end
  end
end
