defmodule AdventOfCode.Puzzles.Year2015.Day03 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule PartA do
    @allowed_instructions ["^", ">", "v", "<"]

    # We want to figure out how many houses Santa visits at least once when following
    # the directional instructions in the form of ^ = N, > = E, v = S, < = W.
    def solve(input) do
      data =
        input
        |> Input.split_by_char("", trim: true)
        |> Enum.filter(&(&1 in @allowed_instructions))

      visited_locations = traverse(data, {0, 0}, [])

      # Get frequency for each location and filter for locations
      # that are visited at least once. Since this is all locations
      # in the list, we simple count uniques instead of frequencies.
      visited_locations
      |> Enum.uniq()
      |> Enum.count()
    end

    # Iterate through the list of instructions and aggregate a list of visited
    # locations that can later be compared for duplicates
    defp traverse([], {_x, _y}, visited), do: visited

    defp traverse([h | t], {x, y}, visited) do
      traverse(t, move({x, y}, h), [{x, y} | visited])
    end

    # Move on the two dimensional grid based on the given directional input
    # This does not limit the grid in any direction.
    defp move({x, y}, "^"), do: {x, y + 1}
    defp move({x, y}, ">"), do: {x + 1, y}
    defp move({x, y}, "v"), do: {x, y - 1}
    defp move({x, y}, "<"), do: {x - 1, y}
  end

  defmodule PartB do
    @allowed_instructions ["^", ">", "v", "<"]

    # We want to figure out how many houses Santa and Robo-Santa visit at least once when
    # following the directional instructions in the form of ^ = N, > = E, v = S, < = W.
    # They take turns interpreting the operations
    def solve(input) do
      data =
        input
        |> Input.split_by_char("", trim: true)
        |> Enum.filter(&(&1 in @allowed_instructions))

      # Instead of writing an alternating iterator, we simply split the list now by
      # taking every second element, once starting at zero and once starting at one.
      santa_data = data |> Enum.take_every(2)
      robos_data = data |> Enum.slice(1..-1) |> Enum.take_every(2)

      santa_locations = traverse(santa_data, {0, 0}, [])
      robos_locations = traverse(robos_data, {0, 0}, [])

      # Get frequency for each location and filter for locations
      # that are visited at least once. Since this is all locations
      # in the list, we simple count uniques instead of frequencies.
      (santa_locations ++ robos_locations)
      |> Enum.uniq()
      |> Enum.count()
    end

    # Iterate through the list of instructions and aggregate a list of visited
    # locations that can later be compared for duplicates
    defp traverse([], {_x, _y}, visited), do: visited

    defp traverse([h | t], {x, y}, visited) do
      traverse(t, move({x, y}, h), [{x, y} | visited])
    end

    # Move on the two dimensional grid based on the given directional input
    # This does not limit the grid in any direction.
    defp move({x, y}, "^"), do: {x, y + 1}
    defp move({x, y}, ">"), do: {x + 1, y}
    defp move({x, y}, "v"), do: {x, y - 1}
    defp move({x, y}, "<"), do: {x - 1, y}
  end
end
