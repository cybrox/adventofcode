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
  def new_from_input(input, mapper \\ & &1) do
    lines = input |> Input.split_by_line(trim: true)
    width = lines |> Enum.at(0) |> byte_size()
    height = lines |> Enum.count()

    new(width, height, fn {r, c} -> lines |> Enum.at(r) |> String.at(c) |> mapper.() end)
  end

  @doc """
  Get the value of a specific field in the grid.
  If the given field is not inside the grid, this returns `nil`.
  Optionally, a default value `default` can be passed to be used instead of `nil`.
  """
  def get(%G{fields: fields}, p, default \\ nil), do: Map.get(fields, p, default)

  @doc """
  Get the values of a row in the grid as a list.
  If the given row is outside the grid, this returns `[]`.
  """
  def get_row(%G{fields: fields}, row), do: fields |> Enum.filter(fn {{r, _}, _} -> r == row end)

  @doc """
  Get the values of a column in the grid as a list.
  If the given column is outside the grid, this returns `[]`.
  """
  def get_col(%G{fields: fields}, col), do: fields |> Enum.filter(fn {{_, c}, _} -> c == col end)

  @doc """
  Get the values of a row in the grid as a string.
  If the given row is outside the grid, this returns `""`.
  """
  def get_row_string(grid, row), do: grid |> get_row(row) |> get_field_string()

  @doc """
  Get the values of a column in the grid as a string.
  If the given column is outside the grid, this returns `""`.
  """
  def get_col_string(grid, col), do: grid |> get_col(col) |> get_field_string()

  defp get_field_string([]), do: nil

  defp get_field_string(fields) do
    fields
    |> Enum.sort_by(fn {k, _} -> k end)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.join("")
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
  Get the distance of two points on the grid.

  This calculates the actual, potentially negative change between points.
  This does not care whether or not the given points are on a valid grid.
  """
  def distance({ra, ca}, {rb, cb}), do: {rb - ra, cb - ca}

  @doc """
  Get the manhattan distance of two points on the grid.

  See: https://en.wikipedia.org/wiki/Taxicab_geometry
  This does not care whether or not the given points are on a valid grid.
  """
  def mh_distance({ra, ca}, {rb, cb}), do: abs(ra - rb) + abs(ca - cb)

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
  Get a list of fields and their contents where the content matches a
  specific matcher function.
  """
  def fields_that_match(%G{fields: fields}, matcher) do
    fields
    |> Enum.filter(fn {_k, v} -> matcher.(v) end)
  end

  @doc """
  Get a list of row indices where all fields match a specific matcher function.
  """
  def rows_that_match(%G{height: height} = grid, matcher) do
    0..(height - 1) |> Enum.filter(fn i -> full_row_matches?(grid, i, matcher) end)
  end

  @doc """
  Get a list of column indices where all fields match a specific matcher function.
  """
  def cols_that_match(%G{width: width} = grid, matcher) do
    0..(width - 1) |> Enum.filter(fn i -> full_col_matches?(grid, i, matcher) end)
  end

  @doc """
  Check whether or not a whole row matches a certain matcher function
  """
  def full_row_matches?(%G{fields: fields}, row, matcher) do
    row_cells = fields |> Enum.filter(fn {{r, _}, _} -> r == row end)
    Enum.all?(row_cells, fn {_, v} -> matcher.(v) end)
  end

  @doc """
  Check whether or not a whole column matches a certain matcher function
  """
  def full_col_matches?(%G{fields: fields}, col, matcher) do
    col_cells = fields |> Enum.filter(fn {{_, c}, _} -> c == col end)
    Enum.all?(col_cells, fn {_, v} -> matcher.(v) end)
  end

  @doc """
  Get the position on top of the passed coordinates on the grid.
  Returns `{:error, :outside}` when the position is not on the grid.
  """
  def top_of(%G{}, {:error, reason}), do: {:error, reason}
  def top_of(%G{}, {0, _}), do: {:error, :outside}
  def top_of(%G{}, {r, c}), do: {r - 1, c}

  @doc """
  Get the position right of the passed coordinates on the grid.
  Returns `{:error, :outside}` when the position is not on the grid.
  """
  def right_of(%G{}, {:error, reason}), do: {:error, reason}
  def right_of(%G{width: w}, {_, c}) when c >= w - 1, do: {:error, :outside}
  def right_of(%G{}, {r, c}), do: {r, c + 1}

  @doc """
  Get the position on the bottom of the passed coordinates on the grid.
  Returns `{:error, :outside}` when the position is not on the grid.
  """
  def bottom_of(%G{}, {:error, reason}), do: {:error, reason}
  def bottom_of(%G{height: h}, {r, _}) when r >= h - 1, do: {:error, :outside}
  def bottom_of(%G{}, {r, c}), do: {r + 1, c}

  @doc """
  Get the position left of the passed coordinates on the grid.
  Returns `{:error, :outside}` when the position is not on the grid.
  """
  def left_of(%G{}, {:error, reason}), do: {:error, reason}
  def left_of(%G{}, {_, 0}), do: {:error, :outside}
  def left_of(%G{}, {r, c}), do: {r, c - 1}

  @doc """
  Get the position on the top right of the passed coordinates on the grid.
  Returns `{:error, :outside}` when the position is not on the grid.
  """
  def top_right_of(%G{} = grid, p), do: top_of(grid, right_of(grid, p))

  @doc """
  Get the position on the bottom right of the passed coordinates on the grid.
  Returns `{:error, :outside}` when the position is not on the grid.
  """
  def bottom_right_of(%G{} = g, p), do: bottom_of(g, right_of(g, p))

  @doc """
  Get the position on the bottom left of the passed coordinates on the grid.
  Returns `{:error, :outside}` when the position is not on the grid.
  """
  def bottom_left_of(%G{} = g, p), do: bottom_of(g, left_of(g, p))

  @doc """
  Get the position on the top left of the passed coordinates on the grid.
  Returns `{:error, :outside}` when the position is not on the grid.
  """
  def top_left_of(%G{} = g, p), do: top_of(g, left_of(g, p))

  @doc """
  Get the adjecant (top, right, bottom, left) positions of the passed coordinates.
  Some of these can be `{:error, :outside}` depending on the grid size.
  """
  def adjecant_of(%G{} = g, p), do: [top_of(g, p), right_of(g, p), bottom_of(g, p), left_of(g, p)]

  @doc """
  Get the diagonal (top-right, bottom-right, bottom-left, top-left) positions of
  the passed coordinates.
  Some of these can be `{:error, :outside}` depending on the grid size.
  """
  def diagonal_of(%G{} = g, p),
    do: [top_right_of(g, p), bottom_right_of(g, p), bottom_left_of(g, p), top_left_of(g, p)]

  @doc """
  Get the surrounding (adjecant and diagonal) positions of the passed coordinates.
  Some of these can be `{:error, :outside}` depending on the grid size.
  """
  def surrounding_of(%G{} = g, p), do: adjecant_of(g, p) ++ diagonal_of(g, p)

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
