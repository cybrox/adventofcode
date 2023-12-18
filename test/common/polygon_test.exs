defmodule AdventOfCode.Common.PoygonTest do
  use ExUnit.Case, async: true

  alias AdventOfCode.Common.Polygon, as: Testee

  @test_vertices1 [
    {0, 0},
    {0, 6},
    {5, 6},
    {5, 4},
    {7, 4},
    {7, 6},
    {9, 6},
    {9, 1},
    {7, 1},
    {7, 0},
    {5, 0},
    {5, 2},
    {2, 2},
    {2, 0},
    {0, 0}
  ]

  @test_vertices2 [
    {10, 5},
    {10, 10},
    {5, 10},
    {5, 5},
    {10, 5}
  ]

  describe "border_area/1" do
    test "computes the correct border area" do
      assert Testee.border_area(@test_vertices1) == 38
      assert Testee.border_area(@test_vertices2) == 20
    end
  end

  describe "area/1" do
    test "computes the correct area" do
      assert Testee.area(@test_vertices1) == 62
      assert Testee.area(@test_vertices2) == 36
    end

    test "area computations are internally consistent" do
      assert inside = Testee.inside_area(@test_vertices1)
      assert border = Testee.border_area(@test_vertices1)
      assert full_a = Testee.area(@test_vertices1)

      assert full_a == inside + border
    end
  end

  describe "inside_area/1" do
    test "computes the correct inside area" do
      assert Testee.inside_area(@test_vertices1) == 24
      assert Testee.inside_area(@test_vertices2) == 16
    end
  end

  describe "horizontal_edges/1" do
    test "computes the correct vertical edges" do
      assert Testee.horizontal_edges(@test_vertices1) == [
               {{0, 0}, {0, 6}},
               {{5, 6}, {5, 4}},
               {{7, 4}, {7, 6}},
               {{9, 6}, {9, 1}},
               {{7, 1}, {7, 0}},
               {{5, 0}, {5, 2}},
               {{2, 2}, {2, 0}}
             ]

      assert Testee.horizontal_edges(@test_vertices2) == [
               {{10, 5}, {10, 10}},
               {{5, 10}, {5, 5}}
             ]
    end
  end

  describe "vertical_edges/1" do
    test "computes the correct vertical edges" do
      assert Testee.vertical_edges(@test_vertices1) == [
               {{0, 6}, {5, 6}},
               {{5, 4}, {7, 4}},
               {{7, 6}, {9, 6}},
               {{9, 1}, {7, 1}},
               {{7, 0}, {5, 0}},
               {{5, 2}, {2, 2}},
               {{2, 0}, {0, 0}}
             ]

      assert Testee.vertical_edges(@test_vertices2) == [
               {{10, 10}, {5, 10}},
               {{5, 5}, {10, 5}}
             ]
    end
  end
end
