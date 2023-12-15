defmodule AdventOfCode.Common.Grid2DTest do
  use ExUnit.Case, async: true

  alias AdventOfCode.Common.Grid2D, as: Testee
  alias AdventOfCode.Common.Grid2D.G, as: G

  describe "new/3" do
    test "properly creates fields with the correct size and value" do
      assert Testee.new(1, 1) == %G{width: 1, height: 1, fields: %{{0, 0} => nil}}

      assert Testee.new(2, 2, 1) == %G{
               width: 2,
               height: 2,
               fields: %{{0, 0} => 1, {0, 1} => 1, {1, 0} => 1, {1, 1} => 1}
             }

      assert Testee.new(3, 3) == %G{
               width: 3,
               height: 3,
               fields: %{
                 {0, 0} => nil,
                 {0, 1} => nil,
                 {0, 2} => nil,
                 {1, 0} => nil,
                 {1, 1} => nil,
                 {1, 2} => nil,
                 {2, 0} => nil,
                 {2, 1} => nil,
                 {2, 2} => nil
               }
             }

      assert Testee.new(1, 3) == %G{
               width: 1,
               height: 3,
               fields: %{
                 {0, 0} => nil,
                 {1, 0} => nil,
                 {2, 0} => nil
               }
             }

      assert Testee.new(4, 1) == %G{
               width: 4,
               height: 1,
               fields: %{
                 {0, 0} => nil,
                 {0, 1} => nil,
                 {0, 2} => nil,
                 {0, 3} => nil
               }
             }
    end

    test "properly creates field with function as default value" do
      assert Testee.new(2, 2, fn {r, c} -> r + c end) == %G{
               width: 2,
               height: 2,
               fields: %{{0, 0} => 0, {0, 1} => 1, {1, 0} => 1, {1, 1} => 2}
             }
    end
  end

  describe "new_from_input/1" do
    test "properly creates field from a given input" do
      assert Testee.new_from_input("123\n456") == %G{
               width: 3,
               height: 2,
               fields: %{
                 {0, 0} => "1",
                 {0, 1} => "2",
                 {0, 2} => "3",
                 {1, 0} => "4",
                 {1, 1} => "5",
                 {1, 2} => "6"
               }
             }

      assert Testee.new_from_input("a\nb\nc\nd\ne") == %G{
               width: 1,
               height: 5,
               fields: %{
                 {0, 0} => "a",
                 {1, 0} => "b",
                 {2, 0} => "c",
                 {3, 0} => "d",
                 {4, 0} => "e"
               }
             }
    end
  end

  describe "get/2" do
    test "returns the correct values" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get(test_grid, {0, 0}) == "1"
      assert Testee.get(test_grid, {0, 3}) == "4"
      assert Testee.get(test_grid, {3, 0}) == "4"
      assert Testee.get(test_grid, {3, 3}) == "7"
      assert Testee.get(test_grid, {2, 1}) == "1"
    end

    test "returns nil when the field does not exist" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get(test_grid, {9, 9}) == nil
    end
  end

  describe "get_row/2" do
    test "returns all fields in a row" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get_row(test_grid, 0) == [
               {{0, 0}, "1"},
               {{0, 1}, "2"},
               {{0, 2}, "3"},
               {{0, 3}, "4"}
             ]

      assert Testee.get_row(test_grid, 3) == [
               {{3, 0}, "4"},
               {{3, 1}, "5"},
               {{3, 2}, "6"},
               {{3, 3}, "7"}
             ]
    end

    test "returns an empty list if the row does not exist" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get_row(test_grid, 9) == []
    end
  end

  describe "get_col/2" do
    test "returns all fields in a col" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get_col(test_grid, 0) == [
               {{0, 0}, "1"},
               {{1, 0}, "5"},
               {{2, 0}, "9"},
               {{3, 0}, "4"}
             ]

      assert Testee.get_col(test_grid, 3) == [
               {{0, 3}, "4"},
               {{1, 3}, "8"},
               {{2, 3}, "3"},
               {{3, 3}, "7"}
             ]
    end

    test "returns an empty list if the col does not exist" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get_col(test_grid, 9) == []
    end
  end

  describe "get_row_string/2" do
    test "returns a properly sorted string representation of the row" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get_row_string(test_grid, 0) == "1234"
      assert Testee.get_row_string(test_grid, 3) == "4567"
    end

    test "returns nil if the row does not exist" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get_row_string(test_grid, 9) == nil
    end
  end

  describe "get_col_string/2" do
    test "returns a properly sorted string representation of the col" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get_col_string(test_grid, 0) == "1594"
      assert Testee.get_col_string(test_grid, 3) == "4837"
    end

    test "returns nil if the col does not exist" do
      test_grid = Testee.new_from_input("1234\n5678\n9123\n4567")

      assert Testee.get_col_string(test_grid, 9) == nil
    end
  end

  #
  # Calculations
  #

  describe "grid_pos/2" do
    test "returns the correct position of an index" do
      test_grid = Testee.new_from_input("abcdef\nghijkl\nmnopqr\nstuvwx")

      assert Testee.grid_pos(test_grid, 0) == {0, 0}
      assert Testee.grid_pos(test_grid, 1) == {0, 1}
      assert Testee.grid_pos(test_grid, 10) == {1, 4}
      assert Testee.grid_pos(test_grid, 23) == {3, 5}
      assert Testee.grid_pos(test_grid, 90) == {15, 0}
    end
  end

  describe "distance/2" do
    test "correctly returns the distance of two points" do
      assert Testee.distance({0, 0}, {2, 2}) == {2, 2}
      assert Testee.distance({2, 2}, {5, 7}) == {3, 5}
      assert Testee.distance({2, 2}, {5, 0}) == {3, -2}
      assert Testee.distance({2, 2}, {0, 7}) == {-2, 5}
      assert Testee.distance({2, 2}, {0, 0}) == {-2, -2}
    end
  end

  describe "mhdistance/2" do
    test "correctly returns the manhattan distance of two points" do
      assert Testee.mh_distance({0, 0}, {2, 2}) == 4
      assert Testee.mh_distance({2, 2}, {5, 7}) == 8
      assert Testee.mh_distance({2, 2}, {5, 0}) == 5
      assert Testee.mh_distance({2, 2}, {0, 7}) == 7
      assert Testee.mh_distance({2, 2}, {0, 0}) == 4
    end
  end

  describe "on_grid?/2" do
    test "returns true for points that are on the grid" do
      test_grid = Testee.new(11, 11)
      assert Testee.on_grid?(test_grid, {0, 0}) == true
      assert Testee.on_grid?(test_grid, {5, 5}) == true
      assert Testee.on_grid?(test_grid, {10, 0}) == true
      assert Testee.on_grid?(test_grid, {10, 10}) == true
    end

    test "returns false for points that are not on the grid" do
      test_grid = Testee.new(11, 11)
      assert Testee.on_grid?(test_grid, {0, -1}) == false
      assert Testee.on_grid?(test_grid, {-1, 0}) == false
      assert Testee.on_grid?(test_grid, {-1, -1}) == false
      assert Testee.on_grid?(test_grid, {10, 11}) == false
      assert Testee.on_grid?(test_grid, {11, 10}) == false
      assert Testee.on_grid?(test_grid, {11, 11}) == false
      assert Testee.on_grid?(test_grid, {2378, -3487}) == false
    end
  end

  describe "fields_in_between/2" do
    test "properly generates a list of fields between coordinates" do
      assert Testee.fields_in_between({0, 0}, {0, 0}) == [{0, 0}]

      assert Testee.fields_in_between({0, 0}, {2, 2}) == [
               {0, 0},
               {0, 1},
               {0, 2},
               {1, 0},
               {1, 1},
               {1, 2},
               {2, 0},
               {2, 1},
               {2, 2}
             ]

      assert big_test = Testee.fields_in_between({10, 10}, {20, 20})
      assert Enum.slice(big_test, 0..2) == [{10, 10}, {10, 11}, {10, 12}]
      assert Enum.slice(big_test, 11..13) == [{11, 10}, {11, 11}, {11, 12}]
      assert Enum.slice(big_test, -3..-1) == [{20, 18}, {20, 19}, {20, 20}]

      assert huge_test = Testee.fields_in_between({10, 10}, {150, 150})
      assert Enum.count(huge_test) == 141 * 141
    end
  end

  describe "fields_that_match/2" do
    test "returns a list of fields that match the specified matcher" do
      test_grid = Testee.new(10, 10, fn {r, c} -> r * c end)

      assert Testee.fields_that_match(test_grid, &(&1 == 0)) |> Enum.count() == 19
      assert Testee.fields_that_match(test_grid, &(&1 < 10)) |> Enum.count() == 42
      assert Testee.fields_that_match(test_grid, &(&1 == 9 * 9)) == [{{9, 9}, 9 * 9}]
      assert Testee.fields_that_match(test_grid, &(&1 > 100)) |> Enum.empty?()
    end
  end

  describe "rows_that_match/2" do
    test "returns a list of row indices that match the specified matcher" do
      test_grid = Testee.new_from_input("abcdef\nghijkl\nzzzzzz\nstuvwx")

      assert Testee.rows_that_match(test_grid, &(&1 == "z")) == [2]
      assert Testee.rows_that_match(test_grid, &(&1 == "a")) == []
    end
  end

  describe "cols_that_match/2" do
    test "returns a list of row indices that match the specified matcher" do
      test_grid = Testee.new_from_input("abcdef\nahijkl\nanopqr\natuvwx")

      assert Testee.cols_that_match(test_grid, &(&1 == "a")) == [0]
      assert Testee.cols_that_match(test_grid, &(&1 == "z")) == []
    end
  end

  describe "full_row_matches?/3" do
    test "correctly identifies whether a row matches" do
      test_grid = Testee.new_from_input("abcdef\nghijkl\nzzzzzz\nstuvwx")

      assert Testee.full_row_matches?(test_grid, 0, &(&1 == "z")) == false
      assert Testee.full_row_matches?(test_grid, 1, &(&1 == "z")) == false
      assert Testee.full_row_matches?(test_grid, 2, &(&1 == "z")) == true
      assert Testee.full_row_matches?(test_grid, 3, &(&1 == "z")) == false
    end
  end

  describe "full_col_matches?/3" do
    test "correctly identifies whether a column matches" do
      test_grid = Testee.new_from_input("abcdef\nahijkl\nanopqr\natuvwx")

      assert Testee.full_col_matches?(test_grid, 0, &(&1 == "a")) == true
      assert Testee.full_col_matches?(test_grid, 1, &(&1 == "a")) == false
      assert Testee.full_col_matches?(test_grid, 2, &(&1 == "a")) == false
      assert Testee.full_col_matches?(test_grid, 3, &(&1 == "a")) == false
    end
  end

  describe "directional functions" do
    @test_grid Testee.new(10, 10)

    test "top_of/2 works as expected" do
      assert Testee.top_of(@test_grid, {0, 0}) == {:error, :outside}
      assert Testee.top_of(@test_grid, {0, 5}) == {:error, :outside}
      assert Testee.top_of(@test_grid, {0, 9}) == {:error, :outside}
      assert Testee.top_of(@test_grid, {1, 9}) == {0, 9}
      assert Testee.top_of(@test_grid, {5, 2}) == {4, 2}
      assert Testee.top_of(@test_grid, {9, 9}) == {8, 9}
    end

    test "top_right_of/2 works as expected" do
      assert Testee.top_right_of(@test_grid, {0, 0}) == {:error, :outside}
      assert Testee.top_right_of(@test_grid, {0, 5}) == {:error, :outside}
      assert Testee.top_right_of(@test_grid, {0, 9}) == {:error, :outside}
      assert Testee.top_right_of(@test_grid, {1, 9}) == {:error, :outside}
      assert Testee.top_right_of(@test_grid, {5, 2}) == {4, 3}
      assert Testee.top_right_of(@test_grid, {9, 9}) == {:error, :outside}
    end

    test "right_of/2 works as expected" do
      assert Testee.right_of(@test_grid, {0, 0}) == {0, 1}
      assert Testee.right_of(@test_grid, {0, 5}) == {0, 6}
      assert Testee.right_of(@test_grid, {0, 9}) == {:error, :outside}
      assert Testee.right_of(@test_grid, {1, 9}) == {:error, :outside}
      assert Testee.right_of(@test_grid, {5, 2}) == {5, 3}
      assert Testee.right_of(@test_grid, {9, 9}) == {:error, :outside}
    end

    test "bottom_right_of/2 works as expected" do
      assert Testee.bottom_right_of(@test_grid, {0, 0}) == {1, 1}
      assert Testee.bottom_right_of(@test_grid, {0, 5}) == {1, 6}
      assert Testee.bottom_right_of(@test_grid, {0, 9}) == {:error, :outside}
      assert Testee.bottom_right_of(@test_grid, {1, 9}) == {:error, :outside}
      assert Testee.bottom_right_of(@test_grid, {5, 2}) == {6, 3}
      assert Testee.bottom_right_of(@test_grid, {9, 9}) == {:error, :outside}
    end

    test "bottom_of/2 works as expected" do
      assert Testee.bottom_of(@test_grid, {0, 0}) == {1, 0}
      assert Testee.bottom_of(@test_grid, {0, 5}) == {1, 5}
      assert Testee.bottom_of(@test_grid, {0, 9}) == {1, 9}
      assert Testee.bottom_of(@test_grid, {1, 9}) == {2, 9}
      assert Testee.bottom_of(@test_grid, {5, 2}) == {6, 2}
      assert Testee.bottom_of(@test_grid, {9, 9}) == {:error, :outside}
    end

    test "bottom_left_of/2 works as expected" do
      assert Testee.bottom_left_of(@test_grid, {0, 0}) == {:error, :outside}
      assert Testee.bottom_left_of(@test_grid, {0, 5}) == {1, 4}
      assert Testee.bottom_left_of(@test_grid, {0, 9}) == {1, 8}
      assert Testee.bottom_left_of(@test_grid, {1, 9}) == {2, 8}
      assert Testee.bottom_left_of(@test_grid, {5, 2}) == {6, 1}
      assert Testee.bottom_left_of(@test_grid, {9, 9}) == {:error, :outside}
    end

    test "left_of/2 works as expected" do
      assert Testee.left_of(@test_grid, {0, 0}) == {:error, :outside}
      assert Testee.left_of(@test_grid, {0, 5}) == {0, 4}
      assert Testee.left_of(@test_grid, {0, 9}) == {0, 8}
      assert Testee.left_of(@test_grid, {1, 9}) == {1, 8}
      assert Testee.left_of(@test_grid, {5, 2}) == {5, 1}
      assert Testee.left_of(@test_grid, {9, 9}) == {9, 8}
    end

    test "top_left_of/2 works as expected" do
      assert Testee.top_left_of(@test_grid, {0, 0}) == {:error, :outside}
      assert Testee.top_left_of(@test_grid, {0, 5}) == {:error, :outside}
      assert Testee.top_left_of(@test_grid, {0, 9}) == {:error, :outside}
      assert Testee.top_left_of(@test_grid, {1, 9}) == {0, 8}
      assert Testee.top_left_of(@test_grid, {5, 2}) == {4, 1}
      assert Testee.top_left_of(@test_grid, {9, 9}) == {8, 8}
      assert Testee.top_left_of(@test_grid, {9, 0}) == {:error, :outside}
    end

    test "adjecant_of/2 works as expected" do
      assert Testee.adjecant_of(@test_grid, {0, 0}) == [
               {:error, :outside},
               {0, 1},
               {1, 0},
               {:error, :outside}
             ]

      assert Testee.adjecant_of(@test_grid, {0, 9}) == [
               {:error, :outside},
               {:error, :outside},
               {1, 9},
               {0, 8}
             ]

      assert Testee.adjecant_of(@test_grid, {9, 0}) == [
               {8, 0},
               {9, 1},
               {:error, :outside},
               {:error, :outside}
             ]

      assert Testee.adjecant_of(@test_grid, {9, 9}) == [
               {8, 9},
               {:error, :outside},
               {:error, :outside},
               {9, 8}
             ]

      assert Testee.adjecant_of(@test_grid, {4, 4}) == [
               {3, 4},
               {4, 5},
               {5, 4},
               {4, 3}
             ]
    end

    test "diagonal_of/2 works as expected" do
      assert Testee.diagonal_of(@test_grid, {0, 0}) == [
               {:error, :outside},
               {1, 1},
               {:error, :outside},
               {:error, :outside}
             ]

      assert Testee.diagonal_of(@test_grid, {0, 9}) == [
               {:error, :outside},
               {:error, :outside},
               {1, 8},
               {:error, :outside}
             ]

      assert Testee.diagonal_of(@test_grid, {9, 0}) == [
               {8, 1},
               {:error, :outside},
               {:error, :outside},
               {:error, :outside}
             ]

      assert Testee.diagonal_of(@test_grid, {9, 9}) == [
               {:error, :outside},
               {:error, :outside},
               {:error, :outside},
               {8, 8}
             ]

      assert Testee.diagonal_of(@test_grid, {4, 4}) == [
               {3, 5},
               {5, 5},
               {5, 3},
               {3, 3}
             ]
    end

    test "surrounding_of/2 works as expected" do
      assert Testee.surrounding_of(@test_grid, {0, 0}) == [
               {:error, :outside},
               {0, 1},
               {1, 0},
               {:error, :outside},
               {:error, :outside},
               {1, 1},
               {:error, :outside},
               {:error, :outside}
             ]

      assert Testee.surrounding_of(@test_grid, {0, 9}) == [
               {:error, :outside},
               {:error, :outside},
               {1, 9},
               {0, 8},
               {:error, :outside},
               {:error, :outside},
               {1, 8},
               {:error, :outside}
             ]

      assert Testee.surrounding_of(@test_grid, {9, 0}) == [
               {8, 0},
               {9, 1},
               {:error, :outside},
               {:error, :outside},
               {8, 1},
               {:error, :outside},
               {:error, :outside},
               {:error, :outside}
             ]

      assert Testee.surrounding_of(@test_grid, {9, 9}) == [
               {8, 9},
               {:error, :outside},
               {:error, :outside},
               {9, 8},
               {:error, :outside},
               {:error, :outside},
               {:error, :outside},
               {8, 8}
             ]

      assert Testee.surrounding_of(@test_grid, {4, 4}) == [
               {3, 4},
               {4, 5},
               {5, 4},
               {4, 3},
               {3, 5},
               {5, 5},
               {5, 3},
               {3, 3}
             ]
    end
  end

  #
  # Grid manipulation
  #

  describe "map_field/3" do
    test "properly maps a single field in a list" do
      test_grid = Testee.new(3, 3, false)

      assert Testee.map_field(test_grid, {0, 0}, &(!&1)) == %AdventOfCode.Common.Grid2D.G{
               width: 3,
               height: 3,
               fields: %{
                 {0, 0} => true,
                 {0, 1} => false,
                 {0, 2} => false,
                 {1, 0} => false,
                 {1, 1} => false,
                 {1, 2} => false,
                 {2, 0} => false,
                 {2, 1} => false,
                 {2, 2} => false
               }
             }

      assert Testee.map_field(test_grid, {1, 1}, &(!&1)) == %AdventOfCode.Common.Grid2D.G{
               width: 3,
               height: 3,
               fields: %{
                 {0, 0} => false,
                 {0, 1} => false,
                 {0, 2} => false,
                 {1, 0} => false,
                 {1, 1} => true,
                 {1, 2} => false,
                 {2, 0} => false,
                 {2, 1} => false,
                 {2, 2} => false
               }
             }

      assert Testee.map_field(test_grid, {2, 1}, &(!&1)) == %AdventOfCode.Common.Grid2D.G{
               width: 3,
               height: 3,
               fields: %{
                 {0, 0} => false,
                 {0, 1} => false,
                 {0, 2} => false,
                 {1, 0} => false,
                 {1, 1} => false,
                 {1, 2} => false,
                 {2, 0} => false,
                 {2, 1} => true,
                 {2, 2} => false
               }
             }
    end

    test "ignores maps outside of the grid" do
      test_grid = Testee.new(3, 3, false)

      assert Testee.map_field(test_grid, {10, 10}, &(!&1)) == test_grid
    end
  end

  describe "map_fields/3" do
    test "properly maps multiple fields in a list" do
      test_grid = Testee.new(3, 3, false)

      assert Testee.map_fields(test_grid, [{0, 0}, {1, 1}, {2, 2}], &(!&1)) ==
               %AdventOfCode.Common.Grid2D.G{
                 width: 3,
                 height: 3,
                 fields: %{
                   {0, 0} => true,
                   {0, 1} => false,
                   {0, 2} => false,
                   {1, 0} => false,
                   {1, 1} => true,
                   {1, 2} => false,
                   {2, 0} => false,
                   {2, 1} => false,
                   {2, 2} => true
                 }
               }

      assert Testee.map_fields(test_grid, [{0, 0}, {0, 1}, {0, 2}], &(!&1)) ==
               %AdventOfCode.Common.Grid2D.G{
                 width: 3,
                 height: 3,
                 fields: %{
                   {0, 0} => true,
                   {0, 1} => true,
                   {0, 2} => true,
                   {1, 0} => false,
                   {1, 1} => false,
                   {1, 2} => false,
                   {2, 0} => false,
                   {2, 1} => false,
                   {2, 2} => false
                 }
               }
    end

    test "ignores empty list of fields to map" do
      test_grid = Testee.new(3, 3, false)

      assert Testee.map_fields(test_grid, [], &(!&1)) == %AdventOfCode.Common.Grid2D.G{
               width: 3,
               height: 3,
               fields: %{
                 {0, 0} => false,
                 {0, 1} => false,
                 {0, 2} => false,
                 {1, 0} => false,
                 {1, 1} => false,
                 {1, 2} => false,
                 {2, 0} => false,
                 {2, 1} => false,
                 {2, 2} => false
               }
             }
    end

    test "ignores maps outside of the grid" do
      test_grid = Testee.new(3, 3, false)

      assert Testee.map_fields(test_grid, [{23, 11}, {-1, 23}, {-324, -4435}], &(!&1)) ==
               %AdventOfCode.Common.Grid2D.G{
                 width: 3,
                 height: 3,
                 fields: %{
                   {0, 0} => false,
                   {0, 1} => false,
                   {0, 2} => false,
                   {1, 0} => false,
                   {1, 1} => false,
                   {1, 2} => false,
                   {2, 0} => false,
                   {2, 1} => false,
                   {2, 2} => false
                 }
               }
    end
  end

  describe "map_between/4" do
    test "properly maps within the specified area" do
      test_grid = Testee.new(3, 3, false)

      assert Testee.map_between(test_grid, {0, 0}, {1, 1}, &(!&1)) ==
               %AdventOfCode.Common.Grid2D.G{
                 width: 3,
                 height: 3,
                 fields: %{
                   {0, 0} => true,
                   {0, 1} => true,
                   {0, 2} => false,
                   {1, 0} => true,
                   {1, 1} => true,
                   {1, 2} => false,
                   {2, 0} => false,
                   {2, 1} => false,
                   {2, 2} => false
                 }
               }

      assert Testee.map_between(test_grid, {1, 0}, {1, 2}, &(!&1)) ==
               %AdventOfCode.Common.Grid2D.G{
                 width: 3,
                 height: 3,
                 fields: %{
                   {0, 0} => false,
                   {0, 1} => false,
                   {0, 2} => false,
                   {1, 0} => true,
                   {1, 1} => true,
                   {1, 2} => true,
                   {2, 0} => false,
                   {2, 1} => false,
                   {2, 2} => false
                 }
               }

      assert Testee.map_between(test_grid, {0, 0}, {2, 2}, &(!&1)) ==
               %AdventOfCode.Common.Grid2D.G{
                 width: 3,
                 height: 3,
                 fields: %{
                   {0, 0} => true,
                   {0, 1} => true,
                   {0, 2} => true,
                   {1, 0} => true,
                   {1, 1} => true,
                   {1, 2} => true,
                   {2, 0} => true,
                   {2, 1} => true,
                   {2, 2} => true
                 }
               }
    end
  end
end
