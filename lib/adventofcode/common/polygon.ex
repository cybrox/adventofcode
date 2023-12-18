defmodule AdventOfCode.Common.Polygon do
  @moduledoc """
  This module provides generic polygon operations on a 2D grid data structure based on
  the `AdventOfCode.Common.Grid2D` module. Since Advent of Code pretty much only uses
  1x1 grids with coordinates instead of continuous cartesian planes, this module is
  optimized for dealing with these use cases.
  """

  @doc """
  Given a list of vertices for a polygon in the `{r, c}` format, this function will calculate the
  area of the border - or in other words, the number of tiles that make up the border.

  This is achieved by pairing the vertices into two-point sides and counting the points within
  the ranges that these sides create, subtracting one for the overlapping square.
  """
  def border_area(vertices) do
    vertices
    |> Enum.chunk_every(2, 1)
    |> Enum.slice(0..-2)
    |> Enum.map(fn
      [{r, ca}, {r, cb}] -> Range.size(ca..cb) - 1
      [{ra, c}, {rb, c}] -> Range.size(ra..rb) - 1
    end)
    |> Enum.sum()
  end

  @doc """
  Given a list of vertices for a polygon in the `{r, c}` format, this function will calculate
  the area of the polygon. In our rasterized grid, this includes the inside, as well as the
  border of the polygon. Essentially, all tiles that are part of it.

  To get just the inside area, use `inside_area/1` instead.

  This function uses the shoelace formula for calculating an "approximate area".
  The shoelace formula yields an exact result for vertices on a continuous plane but since
  we are dealing with a rasterized plane of 1x1 tiles, it includes some of the borders, which
  make up `(b/2)-1` of all border tiles. To account for the additional borders, we apply Pick's
  theorem which states that `A=i+(b/2)-1` where `i` is the tiles inside the polygon and `b` is
  the tiles in the border of the polygon.

  See:
  https://en.wikipedia.org/wiki/Shoelace_formula
  https://en.wikipedia.org/wiki/Pick%27s_theorem
  """
  def area(vertices) do
    shoelace_area =
      vertices
      |> horizontal_edges()
      |> Enum.map(fn {{ra, ca}, {rb, cb}} -> (ra + rb) * (ca - cb) end)
      |> Enum.sum()

    abs(div(shoelace_area, 2)) + div(border_area(vertices), 2) + 1
  end

  @doc """
  Given a list of vertices for a polygon in the `{r, c}` format, this function will calculate
  only the area inside the polygon, ignoring all points that lie on the border.

  To get the full area including the border, use `area/1` instead.

  This function again uses the shoelace formula but instead of using Pick's theorem for adding
  the missing border, it instead subtracts the "erronously" added `b/2` tiles.

  See:
  https://en.wikipedia.org/wiki/Shoelace_formula
  """
  def inside_area(vertices) do
    shoelace_area =
      vertices
      |> horizontal_edges()
      |> Enum.map(fn {{ra, ca}, {rb, cb}} -> (ra + rb) * (ca - cb) end)
      |> Enum.sum()

    abs(div(shoelace_area, 2)) - div(border_area(vertices), 2) + 1
  end

  @doc """
  Given a list of vertices for a polygon in the `{r, c}` format, this function will return
  a list of horizontal edges in the `{{ra, ca}, {rb, cb}}` format.
  """
  def horizontal_edges(vertices) do
    vertices
    |> Enum.chunk_every(2, 1)
    |> Enum.slice(0..-2)
    |> Enum.map(fn [pa, pb] -> {pa, pb} end)
    |> Enum.filter(fn {{_, ca}, {_, cb}} -> ca != cb end)
  end

  @doc """
  Given a list of vertices for a polygon in the `{r, c}` format, this function will return
  a list of vertical edges in the `{{ra, ca}, {rb, cb}}` format.
  """
  def vertical_edges(vertices) do
    vertices
    |> Enum.chunk_every(2, 1)
    |> Enum.slice(0..-2)
    |> Enum.map(fn [pa, pb] -> {pa, pb} end)
    |> Enum.filter(fn {{ra, _}, {rb, _}} -> ra != rb end)
  end
end
