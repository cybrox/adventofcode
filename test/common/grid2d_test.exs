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
    end
  end

  #
  # Calculations
  #

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