defmodule AdventOfCode.Puzzles.Year2015.Day06 do
  require Logger

  alias AdventOfCode.Common.Input
  alias AdventOfCode.Common.Grid2D

  defmodule Shared do
    # Parse a single line of instructions from its text form to a usable tuple.
    # This will extract the type of action (turn on, turn off, toggle) and the
    # `from` and `to` coordinates of the action.
    def parse_instruction(instruction) do
      case String.split(instruction) do
        ["turn", "on", from, "through", to] ->
          {:turn_on, parse_coordinates(from), parse_coordinates(to)}

        ["turn", "off", from, "through", to] ->
          {:turn_off, parse_coordinates(from), parse_coordinates(to)}

        ["toggle", from, "through", to] ->
          {:toggle, parse_coordinates(from), parse_coordinates(to)}
      end
    end

    # Parse a singly `x,y` coordinate string into a tuple of `{x,y}` integers.
    defp parse_coordinates(input) do
      [x, y] = String.split(input, ",")
      {String.to_integer(x), String.to_integer(y)}
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    @grid_size 1000

    # We want to find the number of lights turned on in the grid after all instructions
    # We achieve this by creating a grid of booleans and mapping the instructions onto it.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(&parse_instruction/1)

      grid = Grid2D.new(@grid_size, @grid_size, false)

      final_grid =
        Enum.reduce(data, grid, fn {action, from, to}, grid ->
          Grid2D.map_between(grid, from, to, mapper_for(action))
        end)

      final_grid.fields
      |> Enum.filter(fn {_k, v} -> v end)
      |> Enum.count()
    end

    # Get the mapper function for a given action
    defp mapper_for(:toggle), do: fn v -> !v end
    defp mapper_for(:turn_on), do: fn _ -> true end
    defp mapper_for(:turn_off), do: fn _ -> false end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    @grid_size 1000

    # We want to find the total brightness of all lights in the grid after all instructions
    # We achieve this by creating a grid of zeroes and mapping the instructions onto it.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(&parse_instruction/1)

      grid = Grid2D.new(@grid_size, @grid_size, 0)

      final_grid =
        Enum.reduce(data, grid, fn {action, from, to}, grid ->
          Grid2D.map_between(grid, from, to, mapper_for(action))
        end)

      final_grid.fields
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.sum()
    end

    # Get the mapper function for a given action
    defp mapper_for(:toggle), do: fn v -> v + 2 end
    defp mapper_for(:turn_on), do: fn v -> v + 1 end
    defp mapper_for(:turn_off), do: fn v -> Enum.max([0, v - 1]) end
  end
end
