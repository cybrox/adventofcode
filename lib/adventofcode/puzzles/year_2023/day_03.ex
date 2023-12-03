defmodule AdventOfCode.Puzzles.Year2023.Day03 do
  require Logger

  alias AdventOfCode.Common.Grid2D

  defmodule Shared do
    # Join numbers by shifting through the sorted(!) list of fields with numbers in them.
    # This will get the row and column for the first two items in the list and check if
    # the matches are on the same line (row) and in a subsequent column.
    # If they are, the first value is added to the stack and the whole process is repeated.
    # If they are not, the first value and the stack are added to the accumulator and the
    # stack is cleared, because in that case there was a gap between digits and we want to
    # commit the first number as completed.
    # When there is only one item remaining, we finish the current stack and return the
    # accumulator, that now contains a list of lists which each are a connected number.
    def join_numbers([_], [], acc), do: acc
    def join_numbers([a], stack, acc), do: [stack ++ [a] | acc]

    def join_numbers([{{ra, ca}, _, _} = a, {{rb, cb}, _, _} = b | t], stack, acc) do
      if ra == rb and cb == ca + 1 do
        join_numbers([b | t], stack ++ [a], acc)
      else
        join_numbers([b | t], [], [stack ++ [a] | acc])
      end
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the sum of all numbers in the grid that are surrounded by
    # at least one symbol. A symbol is defined as any value other than a number
    # or an empty field (which the puzzle denotes as `.`).
    def solve(input) do
      grid =
        input
        |> Grid2D.new_from_input()

      # Get all numbers by first finding all the digits on the grid, checking if they are
      # surrounded by a symbol and then passing that information to `join_numbers/3` that
      # will group adjecant digits into numbers.
      numbers_in_grid =
        grid
        |> Grid2D.fields_that_match(&is_number?/1)
        |> Enum.map(&surrounded_by_symbol?(grid, &1))
        |> Enum.sort()
        |> join_numbers([], [])

      # Reduce each multi-digit list into a string representation of the number. This also
      # combines the information whether or not a digit was surrounded by a symbol, so that
      # we end up with a list of `{number, has_symbol}` tuples.
      # Afterwards, we filter out the numbers where no digit had a symbol surrounding it,
      # map the list to only the numbers and calculate their snum.
      numbers_in_grid
      |> Enum.map(fn digits ->
        Enum.reduce(digits, {"", false}, fn {_, v, hs}, {digit, has_symbol} ->
          {digit <> v, has_symbol or hs}
        end)
      end)
      |> Enum.filter(fn {_, has_symbol} -> has_symbol end)
      |> Enum.map(fn {number, _} -> String.to_integer(number) end)
      |> Enum.sum()
    end

    # Check whether or not a field is surroundet by at least one other field that is
    # considered a symbol. Expects the input as `{{r, c}, v}` and returns `{{r, c}, v, hs}`
    # where `r` and `c` are row/column, `v` is the value of the field and `hs` is a boolean
    # indicator of whether or not a symbol was found surrounding the field.
    defp surrounded_by_symbol?(grid, {p, v}) do
      has_sign =
        grid
        |> Grid2D.surrounding_of(p)
        |> Enum.filter(fn p2 -> p2 != {:error, :outside} end)
        |> Enum.any?(fn p2 -> is_symbol?(Map.get(grid.fields, p2)) end)

      {p, v, has_sign}
    end

    # Check if a character is a number by checking its ASCII value.
    defp is_number?(<<c::utf8>>), do: c >= ?0 and c <= ?9

    # Check if a character is a "symbol" (not `.` or `0-9`) by checking its ASCII value.
    defp is_symbol?(<<c::utf8>>), do: c != ?. and (c < ?0 or c > ?9)
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the sum of the products of every two numbers that are adjecant
    # to a gear symbol (`*`). Numbers not adjecant to gear symbols or gear symbols with
    # less or more than one number surrounding them must be ignored.
    def solve(input) do
      grid =
        input
        |> Grid2D.new_from_input()

      # Get all numbers by first finding all the digits on the grid, checking if they are
      # surrounded by a number and then passing that information to `join_numbers/3` that
      # will group adjecant digits into numbers.
      numbers_around_gears =
        grid
        |> Grid2D.fields_that_match(&is_number?/1)
        |> Enum.sort()
        |> Enum.map(&get_gears_around(grid, &1))
        |> join_numbers([], [])

      # Reduce each multi-digit list into a string representation of the number. This also
      # combines the lists of gears around each digit so that we end up with a list of
      # `{number, gears}` tuples.
      #
      # [!] We then map this to only use the first gear position in the list, because I
      # noticed that no number was surrounded by more than one gear in my puzzle input.
      #
      # We then group the list by the `gear` value to get a map of `gear => numbers` where
      # we filter out all gears with not exactly two numbers surrounding them. We then
      # take the sum of the product of all the two-number pairs around gears.
      numbers_around_gears
      |> Enum.map(fn digits ->
        Enum.reduce(digits, {"", []}, fn {_, v, g}, {digits, gears} ->
          {digits <> v, [g | gears]}
        end)
      end)
      |> Enum.map(fn {number, gears} -> {number, gears |> List.flatten() |> Enum.at(0)} end)
      |> Enum.group_by(fn {_, gear} -> gear end, fn {number, _} -> String.to_integer(number) end)
      |> Enum.filter(fn {_, v} -> Enum.count(v) == 2 end)
      |> Enum.map(fn {_, v} -> Enum.product(v) end)
      |> Enum.sum()
    end

    # Get a list of gears around a field. Expects the input as `{{r, c}, v}` and returns
    # `{{r, c}, v, gears}` where `r` and `c` are row/column, `v` is the value of the field
    # and `gears` is a list of positions around the given row/column that contains gears.
    defp get_gears_around(grid, {p, v}) do
      gears_around =
        grid
        |> Grid2D.surrounding_of(p)
        |> Enum.filter(fn v -> v != {:error, :outside} end)
        |> Enum.map(fn p -> {p, Map.get(grid.fields, p)} end)
        |> Enum.filter(fn {_, symbol} -> symbol == "*" end)
        |> Enum.map(fn {p, _} -> p end)

      {p, v, gears_around}
    end

    # Check if a character is a number by checking its ASCII value.
    defp is_number?(<<c::utf8>>), do: c >= ?0 and c <= ?9
  end
end
