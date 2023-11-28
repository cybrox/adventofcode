defmodule AdventOfCode.Puzzles.Year2015.Day01 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule PartA do
    # We want to figure out what floor Santa ends up on following the instructions.
    def solve(input) do
      data =
        input
        |> Input.trim_input()
        |> Input.split_by_character()
        |> Input.remove_empty()

      traverse_foors(data, 0)
    end

    # Traverse through the list of floors starting from the beginning and looking at one
    # floor at a time. If the list is empty, we return the resulting floor number.
    # Otherwise, we calculate the new floor and process the tail recursively.
    defp traverse_foors([], floor), do: floor
    defp traverse_foors([h | t], floor), do: traverse_foors(t, new_floor(floor, h))

    # Calculate the new floor based on the character at the current position. This will
    # increment the current floor by one when encountering `(` and decrement it by one
    # when encountering `)`.
    defp new_floor(floor, "("), do: floor + 1
    defp new_floor(floor, ")"), do: floor - 1
  end

  defmodule PartB do
    # We want to figure out after which instruction Santa arrives at floor `-1`.
    def solve(input) do
      data =
        input
        |> Input.trim_input()
        |> Input.split_by_character()
        |> Input.remove_empty()

      traverse_foors(data, 0, 1)
    end

    # Traverse through the list of floors starting from the beginning and looking at one
    # floor at a time. The iterator `i` is incremented on every iteration. Once we reach
    # floor `-1`, we output the previous iterator. If we never reach floor `-1`, we fail.
    # Otherwise, we calculate the new floor and process the tail recursively.
    defp traverse_foors([], _floor, _i), do: raise("Finished without entering floor -1")
    defp traverse_foors(_input, -1, i), do: i - 1
    defp traverse_foors([h | t], floor, i), do: traverse_foors(t, new_floor(floor, h), i + 1)

    # Calculate the new floor based on the character at the current position. This will
    # increment the current floor by one when encountering `(` and decrement it by one
    # when encountering `)`.
    defp new_floor(floor, "("), do: floor + 1
    defp new_floor(floor, ")"), do: floor - 1
  end
end
