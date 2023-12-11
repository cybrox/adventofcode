defmodule AdventOfCode.Puzzles.Year2023.Day11 do
  require Logger

  alias AdventOfCode.Common.Grid2D

  defmodule Shared do
    # Find all possible distances between a list of galaxies.
    # This only accounts for each pair of galaxies once by popping the first element
    # off the list and calculating its distances to all the remaining galaxies using
    # `get_distance/3`. Once the list of galaxies has only one element remaining, we
    # return the accumulator with all calculated distances.
    def find_distances([_], _, _, acc), do: acc

    def find_distances([h | t], empties, multipier, acc) do
      new_distances = t |> Enum.map(fn to -> get_distance(h, to, empties, multipier) end)
      find_distances(t, empties, multipier, acc ++ new_distances)
    end

    # Get the distance between two points `pa` and `pb`, respecting the empty rows `er`
    # and empty columns `ec`, which will both count for an additional `mult` times per
    # occurance to account for the "expansion" of the universion.
    # We calculate the expansion space by sorting the row and column numbers of both points
    # in ascending order, generate a range from that and count all values in between where
    # the given row/col index is in the empty row/col information and multiply that by `mult - 1`.
    # We reduce the multiplier by one because the first instance is included in the mh_distance.
    defp get_distance({ra, ca} = pa, {rb, cb} = pb, {er, ec}, mult) do
      [r1, r2] = Enum.sort([ra, rb])
      [c1, c2] = Enum.sort([ca, cb])

      n_er = r1..r2 |> Enum.count(&(&1 in er))
      n_ec = c1..c2 |> Enum.count(&(&1 in ec))

      Grid2D.mh_distance(pa, pb) + n_er * (mult - 1) + n_ec * (mult - 1)
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the sum of all the shortest paths between alls the galaxies.
    # The catch is that empty rows and columns count twice instead of only once.
    def solve(input) do
      grid = Grid2D.new_from_input(input)

      empty_rows = Grid2D.rows_that_match(grid, &(&1 == "."))
      empty_cols = Grid2D.cols_that_match(grid, &(&1 == "."))
      galaxies = Grid2D.fields_that_match(grid, &(&1 == "#")) |> Enum.map(fn {p, _} -> p end)

      galaxies
      |> find_distances({empty_rows, empty_cols}, 2, [])
      |> Enum.sum()
    end
  end

  defmodule PartB do
    @dist_multiplier 1_000_000

    use AdventOfCode.Common.Shared

    # We want to find the sum of all the shortest paths between alls the galaxies.
    # The catch is that empty rows and columns now count 1'000'000x instead of only once.
    def solve(input) do
      grid = Grid2D.new_from_input(input)

      empty_rows = Grid2D.rows_that_match(grid, &(&1 == "."))
      empty_cols = Grid2D.cols_that_match(grid, &(&1 == "."))
      galaxies = Grid2D.fields_that_match(grid, &(&1 == "#")) |> Enum.map(fn {p, _} -> p end)

      galaxies
      |> find_distances({empty_rows, empty_cols}, @dist_multiplier, [])
      |> Enum.sum()
    end
  end
end
