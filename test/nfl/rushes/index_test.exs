defmodule Nfl.Rushes.IndexTest do
  alias Nfl.Rushes.Index
  use Nfl.DataCase, async: true

  describe "rushes_all/2 no data" do
    test "return empty list" do
      assert [] == Index.rushes_all()
    end
  end

  describe "rushes_all/2 with data" do
    setup do
      rushes = insert_list(10, :rush)

      {:ok, rushes: rushes}
    end

    test "when no filter or sort is given, " <>
           "return rushes ordered by player name",
         %{rushes: rushes} do
      rushes_alfabetical = Enum.sort_by(rushes, & &1.player.name, :asc)

      assert rushes_alfabetical == Index.rushes_all()
    end

    test "when filter by player name is given, " <>
           "return rushes with player name or similar",
         %{rushes: [rush | _] = rushes} do
      name_part = String.slice(rush.player.name, 0..3)

      rushes_with_name_part =
        rushes
        |> Enum.filter(&String.contains?(&1.player.name, name_part))
        |> Enum.sort_by(& &1.player.name, :asc)

      assert rushes_with_name_part == Index.rushes_all([], player: name_part)
    end

    for sort <- ~w(longest_rush total_rushing_touchdowns total_rushing_yards)a do
      @tag sort: sort

      test "when sort by asc #{sort} is given, return rushes sorted by asc #{sort}",
           %{rushes: rushes, sort: sort} do
        rushes_longest_asc =
          rushes
          |> Enum.sort_by(& &1.player.name, :asc)
          |> Enum.sort_by(&Map.get(&1, sort), :asc)

        sort_string = Atom.to_string(sort)

        assert rushes_longest_asc ==
                 Index.rushes_all([{"asc", sort_string}], [])
      end

      @tag sort: sort
      test "when sort by desc #{sort} is given, return rushes sorted by desc #{sort}",
           %{rushes: rushes, sort: sort} do
        rushes_longest_desc =
          rushes
          |> Enum.sort_by(& &1.player.name, :asc)
          |> Enum.sort_by(&Map.get(&1, sort), :desc)

        sort_string = Atom.to_string(sort)

        assert rushes_longest_desc ==
                 Index.rushes_all([{"desc", sort_string}], [])
      end

      @tag sort: sort
      test "when sort by asc and desc #{sort} is given, return rushes sorted by asc #{sort}",
           %{rushes: rushes, sort: sort} do
        rushes_longest_asc =
          rushes
          |> Enum.sort_by(& &1.player.name, :asc)
          |> Enum.sort_by(&Map.get(&1, sort))

        sort_string = Atom.to_string(sort)

        # The first filter is always stronger
        assert rushes_longest_asc ==
                 Index.rushes_all([{"asc", sort_string}, {"desc", sort_string}], [])
      end

      @tag sort: sort
      test "when filters and #{sort} are passed, return filtered and sorted by #{sort}",
           %{rushes: [rush | _] = rushes, sort: sort} do
        name_part = String.slice(rush.player.name, 0..3)

        rushes_with_name_part = Enum.filter(rushes, &String.contains?(&1.player.name, name_part))

        rushes_longest_asc =
          rushes_with_name_part
          |> Enum.sort_by(& &1.player.name, :asc)
          |> Enum.sort_by(&Map.get(&1, sort))

        sort_string = Atom.to_string(sort)

        assert rushes_longest_asc ==
                 Index.rushes_all([{"asc", sort_string}], player: name_part)
      end
    end
  end
end
