defmodule AdventOfCode.Puzzles.Year2023.Day16 do
  require Logger

  alias AdventOfCode.Common.Grid2D

  defmodule Shared do
    # Get the number of fields that light up from a beam traversing through the grid.
    def beam_traversal_lights(grid, beams) do
      beam_traverse(grid, beams, [])
      |> Enum.map(fn {p, _} -> p end)
      |> Enum.uniq()
      |> Enum.count()
    end

    # Have a list of beams traverse through the grid.
    # For each currently active beam, this will look up the next tile in its path and create
    # a list of new beams depending on that. For example a beam going right into a `-` will
    # create one new beam still going right at that position, whereas a beam going downwards
    # into a `-` will create two beams at that position, one going left and another goign
    # right. To prevent infinite loops, we keep a list of visited `{point, direction}`, which
    # allows us to ignore a beam if it starts treading a known path.
    def beam_traverse(_grid, [], visited), do: visited

    def beam_traverse(grid, beams, visited) do
      new_beams =
        Enum.reduce(beams, [], fn {p, dir_fun}, acc ->
          next_point = dir_fun.(grid, p)
          next = Grid2D.get(grid, next_point)

          cond do
            # Beam has reached the edge of the field, terminate it
            next == nil ->
              acc

            # Beam encounters empty space, continue in current direction
            next == "." ->
              acc ++ [{next_point, dir_fun}]

            # Beam encounters a mirror, change direction by 90 degrees
            next == "/" and dir_fun == (&Grid2D.top_of/2) ->
              acc ++ [{next_point, &Grid2D.right_of/2}]

            next == "/" and dir_fun == (&Grid2D.right_of/2) ->
              acc ++ [{next_point, &Grid2D.top_of/2}]

            next == "/" and dir_fun == (&Grid2D.bottom_of/2) ->
              acc ++ [{next_point, &Grid2D.left_of/2}]

            next == "/" and dir_fun == (&Grid2D.left_of/2) ->
              acc ++ [{next_point, &Grid2D.bottom_of/2}]

            next == "\\" and dir_fun == (&Grid2D.top_of/2) ->
              acc ++ [{next_point, &Grid2D.left_of/2}]

            next == "\\" and dir_fun == (&Grid2D.right_of/2) ->
              acc ++ [{next_point, &Grid2D.bottom_of/2}]

            next == "\\" and dir_fun == (&Grid2D.bottom_of/2) ->
              acc ++ [{next_point, &Grid2D.right_of/2}]

            next == "\\" and dir_fun == (&Grid2D.left_of/2) ->
              acc ++ [{next_point, &Grid2D.top_of/2}]

            # Beam encounters a `-` splitter
            next == "-" and dir_fun in [&Grid2D.left_of/2, &Grid2D.right_of/2] ->
              acc ++ [{next_point, dir_fun}]

            next == "-" and dir_fun in [&Grid2D.top_of/2, &Grid2D.bottom_of/2] ->
              acc ++ [{next_point, &Grid2D.left_of/2}, {next_point, &Grid2D.right_of/2}]

            # Beam encounters a `|` splitter
            next == "|" and dir_fun in [&Grid2D.top_of/2, &Grid2D.bottom_of/2] ->
              acc ++ [{next_point, dir_fun}]

            next == "|" and dir_fun in [&Grid2D.left_of/2, &Grid2D.right_of/2] ->
              acc ++ [{next_point, &Grid2D.top_of/2}, {next_point, &Grid2D.bottom_of/2}]
          end
        end)
        |> Enum.filter(fn {p, _} -> p != {:error, :outside} end)
        |> Enum.filter(fn move -> move not in visited end)

      beam_traverse(grid, new_beams, visited ++ new_beams)
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the total number of tiles that light up from a beam starting from the
    # top left of the grid towards the right. To figure this out, we traverse the grid using
    # that beam as an initial input and then mapping the resulting list of visited locations
    # into just their points (as a point can occurr multiple times with different directions
    # but light does not interfer or accumulte) and count the number of unique fields.
    def solve(input) do
      grid = Grid2D.new_from_input(input)

      beam_traversal_lights(grid, [{{0, -1}, &Grid2D.right_of/2}])
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the starting position around the grid where a beam moving inwards from
    # there will light up the most tiles possible. The smart approach for this would be using
    # dynamic programming to keep a list of tiles/directions and their resulting chain in
    # memory but I was too lazy so I just brute-force it by checking all possible starting
    # points with a complete simulation and take the maximum.
    def solve(input) do
      grid = Grid2D.new_from_input(input)

      top_starts = for c <- 0..(grid.width - 1), do: {-1, c}
      bottom_starts = for c <- 0..(grid.width - 1), do: {grid.height, c}
      right_starts = for r <- 1..(grid.height - 2), do: {r, grid.width}
      left_starts = for r <- 1..(grid.height - 2), do: {r, -1}

      possible_starts = [
        top_starts |> Enum.map(fn p -> {p, &Grid2D.bottom_of/2} end),
        bottom_starts |> Enum.map(fn p -> {p, &Grid2D.top_of/2} end),
        right_starts |> Enum.map(fn p -> {p, &Grid2D.left_of/2} end),
        left_starts |> Enum.map(fn p -> {p, &Grid2D.right_of/2} end)
      ]

      possible_starts
      |> List.flatten()
      |> Enum.map(fn start -> beam_traversal_lights(grid, [start]) end)
      |> Enum.max()
    end
  end
end
