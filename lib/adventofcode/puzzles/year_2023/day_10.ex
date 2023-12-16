defmodule AdventOfCode.Puzzles.Year2023.Day10 do
  require Logger

  alias AdventOfCode.Common.Grid2D

  defmodule Shared do
    # Traverse the animal step by step.
    # This looks at all of the surrouding tiles of the current tile, removes the head of the
    # accumulator (the last field we visited) from it and looks for one that is a valid part
    # of the animal. By the puzzles definition, each field of the animal has exactly two
    # properly connected fields, one of which will be the last (`h`) and the other one the next.
    # Once we find no un-visited fields anymore, we have found the full animal.
    def traverse_animal(grid, next, [h | t] = acc) do
      case linked_fields(grid, next) -- [h] do
        [] -> acc
        [new_next] -> traverse_animal(grid, new_next, [next, h | t])
      end
    end

    # Get the possible linked fields for any part of the animal depending on the caracter.
    def linked_fields(g, p) do
      case Grid2D.get(g, p) do
        "|" -> [Grid2D.top_of(g, p), Grid2D.bottom_of(g, p)]
        "-" -> [Grid2D.right_of(g, p), Grid2D.left_of(g, p)]
        "L" -> [Grid2D.top_of(g, p), Grid2D.right_of(g, p)]
        "J" -> [Grid2D.top_of(g, p), Grid2D.left_of(g, p)]
        "7" -> [Grid2D.bottom_of(g, p), Grid2D.left_of(g, p)]
        "F" -> [Grid2D.bottom_of(g, p), Grid2D.right_of(g, p)]
        "S" -> []
        "." -> []
      end
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find farthest point of the animal, which is a single continuous loop as
    # stated in the puzzle. To do this, we find the position of the start tile (`S`), look
    # at all of the surrounding tiles, filter for the two that are valid parts of the animal
    # and pick the first one (we could go either direction).
    # We then traverse the animal completely and divide the resulting full length by two
    # to get the point that is the farthest (by walking distance) from the start.
    def solve(input) do
      grid = Grid2D.new_from_input(input)

      {start_tile, "S"} = grid |> Grid2D.fields_that_match(&(&1 == "S")) |> Enum.at(0)
      start_options = grid |> Grid2D.adjecant_of(start_tile)

      search_start_tile =
        start_options
        |> Enum.filter(&(&1 != {:error, :outside}))
        |> Enum.map(fn p -> {p, linked_fields(grid, p)} end)
        |> Enum.filter(fn {_, links} -> start_tile in links end)
        |> Enum.map(fn {p, _} -> p end)
        |> Enum.at(0)

      traverse_animal(grid, search_start_tile, [start_tile])
      |> Enum.count()
      |> Kernel./(2)
      |> floor()
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the total number of tiles that are completely enclosed by the animal
    # and make up its nest. There are multiple ways to do this. One possible way would be
    # to scale up the whole grid so we can flood-fill between adjecant parts of the animal
    # to reach all areas inside the animal and then count the ones not adjecant to an enlarged
    # part of the animal.
    #
    # However, I insisted on solving this with a point-in-polygon algorithm but both even/odd
    # and winding number had some hard to solve edge-cases with colinear vertices on a simple
    # 2D grid. I ended up implementing the algorithm described in:
    #  An Extension to Winding Number and Point-in-Polygon Algorithm
    #  by G. Naresh Kumar ∗ and Mallikarjun. Bangi 2018
    #  https://www.sciencedirect.com/science/article/pii/S2405896318302568
    #
    # We first traverse the animal like in part A to obtain all fields that are part of it.
    # Then, we determine all the vertices of the animal (which may or may not include `S`).
    # Afterwards, we map each field of the grid which is not part of the animal to its winding
    # number result (`wn`) and count the ones where `wn != 0`.
    def solve(input) do
      grid = Grid2D.new_from_input(input)

      {start_tile, "S"} = grid |> Grid2D.fields_that_match(&(&1 == "S")) |> Enum.at(0)
      start_options = grid |> Grid2D.adjecant_of(start_tile)

      [start_a, start_b] =
        start_options
        |> Enum.filter(&(&1 != {:error, :outside}))
        |> Enum.map(fn p -> {p, linked_fields(grid, p)} end)
        |> Enum.filter(fn {_, links} -> start_tile in links end)
        |> Enum.map(fn {p, _} -> p end)

      # Get a tile filter depending on wheter or not we also filter `S`
      filter_start_tile = filter_start_tile?(start_b, start_tile, start_a)
      filtered_tiles = if filter_start_tile, do: ["S", "-", "|"], else: ["-", "|"]

      animal_fields = traverse_animal(grid, start_a, [start_tile])

      # Get a list of all animal vertices
      animal_vertices =
        animal_fields
        |> Enum.filter(fn p -> Grid2D.get(grid, p) not in filtered_tiles end)

      # Get a list of vertice pairs that we can check against
      animal_sides =
        animal_vertices
        |> Enum.chunk_every(2, 1, [Enum.at(animal_vertices, 0)])

      grid.fields
      |> Enum.map(fn {p, _} -> p end)
      |> Enum.filter(fn p -> p not in animal_fields end)
      |> Enum.map(fn {r, c} -> {r, c, calculate_wn({r, c}, animal_sides)} end)
      |> Enum.filter(fn {_, _, wn} -> wn != 0 end)
      |> Enum.count()
    end

    # Calculate the winding number for a specific point
    defp calculate_wn({r, c}, animal_sides) do
      animal_sides
      |> Enum.filter(fn [{_, ca}, {_, cb}] -> ca > c and cb > c end)
      |> Enum.reduce(0, fn [{ra, _}, {rb, _}], acc ->
        cond do
          # Both vertices colinear with point, do nothing
          ra == rb -> acc
          # Both vertices below or above point, do nothing
          ra > r and rb > r -> acc
          ra < r and rb < r -> acc
          # Edge intersects ray from point upward or downward
          ra < r and rb > r -> acc + 1
          ra > r and rb < r -> acc - 1
          # Edge 'intersects' upward or downward up to a colinear point
          ra < r and rb == r -> acc + 0.5
          ra > r and rb == r -> acc - 0.5
          rb < r and ra == r -> acc - 0.5
          rb > r and ra == r -> acc + 0.5
        end
      end)
    end

    # Determine if we filter `S`. This is the case if `S` is not a vertex but part of a side.
    defp filter_start_tile?({ra, ca}, {rb, cb}, {rc, cc}) do
      ra == rb and ra == rc and ca + 2 == cc and cb + 1 == cc
    end
  end
end
