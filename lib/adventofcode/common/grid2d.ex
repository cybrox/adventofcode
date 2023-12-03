defmodule AdventOfCode.Common.Grid2D do
  @moduledoc """
  This module provides a 2D grid data structure that can be used to solve puzzles where
  navigation, movement, and/or coordinates on a 2D grid are required.
  The grid uses the cartesian plane starting at 0/0 by default.

  Instead of X/Y coordinates, we use R/C (row and column) coordinates. This is because it
  is both easier to read and easier to process when rows are the top-level list, which
  means coordinates would need to be written as Y/X, which is arguably more confusing than R/C.
  """

  alias AdventOfCode.Common.Input

  defmodule G do
    defstruct [:width, :height, :fields]
  end

  @doc """
  Generate a new 2D grid with the specified width and height.
  The default value for each field is `nil` unless another default is provided.
  """
  def new(width, height, default \\ nil) do
    fields = for r <- 0..(height - 1), do: for(c <- 0..(width - 1), do: {r, c})

    field_map =
      fields
      |> List.flatten()
      |> Enum.into(%{}, fn p -> {p, apply_default(default, p)} end)

    %G{width: width, height: height, fields: field_map}
  end

  defp apply_default(default, p) when is_function(default), do: default.(p)
  defp apply_default(default, _), do: default

  @doc """
  Generate a new 2D grid from an input string.
  This will determine the width and height based on the number of lines and their length.
  """
  def new_from_input(input) do
    lines = input |> Input.split_by_line(trim: true)
    width = lines |> Enum.at(0) |> byte_size()
    height = lines |> Enum.count()

    new(width, height, fn {r, c} -> lines |> Enum.at(r) |> String.at(c) end)
  end

  @doc """
  Debug print a field
  """
  def debug_print(%G{width: width, height: height, fields: field_map}) do
    IO.puts("Debug-printing field with width #{width} and height #{height}")

    field_map
    |> Enum.sort()
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.chunk_every(width)
    |> IO.inspect()
  end

  #
  # Calculations
  #

  @doc """
  Assuming the grid unwrapped as a single long string, map the index in that
  string to the coordinates in the actual field. This does not count newlines
  or any other characters potentially present in a previous input string.

  For a 4x6 grid, the input `10` would yield `{1, 4}` (one full row + four)0
  This does not verify whether or not the point is possible within the actual
  grid. This needs to be checked separately with `on_grid?/2`.
  """
  def grid_pos(%G{width: w, height: _h}, n) do
    {floor(n / w), rem(n, w)}
  end

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

  @doc """
  Get a list of fienlds and their contents where the content matches a
  specific matcher function.
  """
  def fields_that_match(%G{fields: fields}, matcher) do
    fields
    |> Enum.filter(fn {_k, v} -> matcher.(v) end)
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
