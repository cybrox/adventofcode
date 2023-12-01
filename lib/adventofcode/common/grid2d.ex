defmodule AdventOfCode.Common.Grid2D do
  @moduledoc """
  This module provides a 2D grid data structure that can be used to solve puzzles where
  navigation, movement, and/or coordinates on a 2D grid are required.
  The grid uses the cartesian plane starting at 0/0 by default.
  """

  defmodule G do
    defstruct [:width, :height, :fields]
  end

  @doc """
  Generate a new 2D grid with the specified width and height.
  The default value for each field is `nil` unless another default is provided.
  """
  def new(width, height, default \\ nil) do
    fields = for x <- 0..(width - 1), do: for(y <- 0..(height - 1), do: {x, y})
    field_map = fields |> List.flatten() |> Enum.into(%{}, fn p -> {p, default} end)
    %G{width: width, height: height, fields: field_map}
  end

  #
  # Calculations
  #

  @doc """
  Check whether or not a coordinate exists within the given grid
  """
  def on_grid?(%G{width: w, height: h}, {x, y}) do
    x >= 0 and x <= w - 1 and y >= 0 and y <= h - 1
  end

  @doc """
  Get a list of fields in the grid between `row_a/col_a` and `row_b/col_b`.

  This will include both the leading and the trailing row by default, so
  getting all fields between `0/0` and `3/3` will include `0/0` and `3/3`.
  """
  def fields_in_between({row_a, col_a}, {row_b, col_b}) do
    for r <- row_a..row_b, c <- col_a..col_b, do: {r, c}
  end

  #
  # Grid manipulation
  #

  @doc """
  Apply a mapper function to a single field in a grid.

  Fields that are outside of the specified grid are simply ignored.
  """
  def map_field(%G{fields: fields} = grid, {x, y}, mapper) do
    if on_grid?(grid, {x, y}) do
      old_value = Map.get(fields, {x, y})
      new_value = mapper.(old_value)

      Map.put(grid, :fields, Map.put(fields, {x, y}, new_value))
    else
      grid
    end
  end

  @doc """
  Apply a mapper function to multiple fields in a grid.

  Fields that are outside of the specified grid are simply ignored.
  """
  def map_fields(grid, [], _mapper), do: grid
  def map_fields(grid, [h | t], mapper), do: map_fields(map_field(grid, h, mapper), t, mapper)

  @doc """
  Apply a mapper function to all fields between two coordinates.

  This will use `fields_in_between/2` to generate a list of fields to modify
  and then use `map_fields` to map all of them efficiently.
  """
  def map_between(grid, {row_a, col_a}, {row_b, col_b}, mapper) do
    fields_to_map = fields_in_between({row_a, col_a}, {row_b, col_b})
    map_fields(grid, fields_to_map, mapper)
  end
end
