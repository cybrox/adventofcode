defmodule AdventOfCode.Puzzles.Year2023.Day13 do
  require Logger

  alias AdventOfCode.Common.Grid2D
  alias AdventOfCode.Common.Input

  defmodule PartA do
    # We want to find all the mirror points for all grids where the grids are mirrored either
    # horizontally or vertically. After that, we want to sum the the number of lines left of
    # mirror points and 100 times all the lines on top of mirror points.
    def solve(input) do
      grids =
        input
        |> Input.split_by_char("\n\n", trim: true)
        |> Enum.map(&Grid2D.new_from_input/1)

      grids
      |> Enum.map(&find_mirror/1)
      |> Enum.map(fn
        {:horizontal, n} -> n * 100
        {:vertical, n} -> n
      end)
      |> Enum.sum()
    end

    # Find all possible mirror points in both directions on a grid.
    # This expects only one valid mirror point per grid to exist.
    defp find_mirror(grid) do
      possible_points = [
        find_mirror(grid, 0..(grid.height - 1), &Grid2D.get_row_string/2, :horizontal),
        find_mirror(grid, 0..(grid.width - 1), &Grid2D.get_col_string/2, :vertical)
      ]

      possible_points
      |> Enum.filter(&(&1 != nil))
      |> Enum.at(0)
    end

    # Find all possible mirror points in the grid in a given direction
    # A possible mirror point are two identical adjecant rows or columns.
    # To calculate these, we get all the rows or cols from the grid, chunk them into pairs of two
    # and compare them. After finding potential mirror points, we validate if they properly mirror
    # across the whole grid and then return them with direction.
    defp find_mirror(grid, range, getter, direction) do
      range
      |> Enum.map(fn row -> {row + 1, grid |> getter.(row)} end)
      |> Enum.chunk_every(2, 1, [{0, ""}])
      |> Enum.filter(fn [{_, a}, {_, b}] -> a == b end)
      |> Enum.filter(fn [{a, _}, {b, _}] -> validate_mirror_point(grid, a, b, getter) end)
      |> Enum.map(fn [{n, _}, _] -> {direction, n} end)
      |> Enum.at(0)
    end

    # Check if a mirror point is valid across the whole grid.
    # A mirror point is considered valid if all subsequent rows or columns are also mirrored
    # until the edge of the grid is reached on either side.
    defp validate_mirror_point(grid, a, b, getter) do
      data_a = getter.(grid, a - 1)
      data_b = getter.(grid, b - 1)

      cond do
        data_a == nil or data_b == nil -> true
        data_a == data_b -> validate_mirror_point(grid, a - 1, b + 1, getter)
        true -> false
      end
    end
  end

  defmodule PartB do
    # We still want to find all of the mirror points, however now each mirror can have one
    # smudge, which means a single character can be changed and the old mirror points are no
    # longer valid. To find all new mirror points, we first find all the original mirror points
    # like in part A and then find all mirror points that are possible with either zero or one
    # change of character (smudge). This allows us to remove the old mirror points from the
    # resulting list of mirror points, which leaves us with the new mirror points that we can
    # sum up like before.
    def solve(input) do
      grids =
        input
        |> Input.split_by_char("\n\n", trim: true)
        |> Enum.map(&Grid2D.new_from_input/1)

      without_smudge = grids |> Enum.map(&find_mirror(&1, 0))
      with_smudge = grids |> Enum.map(&find_mirror(&1, 1))

      Enum.zip(with_smudge, without_smudge)
      |> Enum.map(fn {all, old} -> Enum.at(all -- old, 0) end)
      |> Enum.map(fn
        {:horizontal, n} -> n * 100
        {:vertical, n} -> n
      end)
      |> Enum.sum()
    end

    # Find all possible mirror points in both directions on a grid.
    defp find_mirror(grid, fuzz) do
      possible_points = [
        find_mirror(grid, 0..(grid.height - 1), &Grid2D.get_row_string/2, :horizontal, fuzz),
        find_mirror(grid, 0..(grid.width - 1), &Grid2D.get_col_string/2, :vertical, fuzz)
      ]

      possible_points
      |> List.flatten()
    end

    # Find all possible mirror points in the grid in a given direction
    # A possible mirror point are two adjecant rows or columns that differ by no more than
    # `fuzz` characters. To calculate these, we get all the rows or cols from the grid, chunk
    # them into pairs of two and compare them. After finding potential mirror points, we
    # validate if they properly mirror across the whole grid and then return them with direction.
    defp find_mirror(grid, range, getter, direction, fuzz) do
      range
      |> Enum.map(fn row -> {row + 1, grid |> getter.(row)} end)
      |> Enum.chunk_every(2, 1, [{0, ""}])
      |> Enum.filter(fn [{_, a}, {_, b}] -> char_difference(a, b) <= fuzz end)
      |> Enum.filter(fn [{a, _}, {b, _}] -> validate_mirror_point(grid, a, b, getter, fuzz, 0) end)
      |> Enum.map(fn [{n, _}, _] -> {direction, n} end)
    end

    # Check if a mirror point is valid across the whole grid.
    # A mirror point is considered valid if all subsequent rows or columns are also mirrored
    # until the edge of the grid is reached on either side.
    # Unlike in part A, we now allow a specific number of characters to be different across
    # the whole mirroring sequence, specified by `fuzz`.
    defp validate_mirror_point(grid, a, b, getter, fuzz, diff) do
      data_a = getter.(grid, a - 1)
      data_b = getter.(grid, b - 1)

      cond do
        diff > fuzz ->
          false

        data_a == nil or data_b == nil ->
          true

        true ->
          new_diff = diff + char_difference(data_a, data_b)
          validate_mirror_point(grid, a - 1, b + 1, getter, fuzz, new_diff)
      end
    end

    # Returns the number of different characters in two strings with identical length.
    # The two initial cases are added for catching comparison to empty strings, which
    # will happen when the edge of the grid is reached.
    # This recursively pops the first characters off both strings and adds their difference
    # (which is 0 or 1) to the accumulator, until both strings are empty.
    defp char_difference("", _), do: :infinity
    defp char_difference(_, ""), do: :infinity
    defp char_difference(a, b), do: char_difference(a, b, 0)

    defp char_difference("", "", diff), do: diff

    defp char_difference(<<a::utf8, rest_a::binary>>, <<b::utf8, rest_b::binary>>, diff),
      do: char_difference(rest_a, rest_b, diff + char_diff_for(a, b))

    # Get the difference between to characters.
    # This is 0 if they are the same and 1 if they are not.
    defp char_diff_for(a, a), do: 0
    defp char_diff_for(_a, _b), do: 1
  end
end
