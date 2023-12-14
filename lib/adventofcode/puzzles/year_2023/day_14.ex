defmodule AdventOfCode.Puzzles.Year2023.Day14 do
  require Logger

  alias AdventOfCode.Common.Grid2D

  defmodule Shared do
    # Tilt the whole grid to one side. This is achieved by passing a grid and a function
    # `next_mapper`, which must convert `{r, c}` coordinates into the next position from
    # that point, assuming the grid is tilted. For example, when tilting the grid north or "up",
    # the `next_mapper` should be `{r,c} -> {r-1,c}` to move north/"up" by one row.
    #
    # This function generates a list of all fields to calculate starting from {0,0}, which is
    # the top left and then applies rules to all of them. This is done because maps (e.g. the)
    # grid fields are not necessarily in order in Elixir.
    #
    # For each position, we look at the position on its "next position" (e.g. above) and determine
    # what to do depending on the type of field we are and the type of field the next position is.
    # We repeat this process until no boulders were rolled, indicating there is no more possible
    # change when repeating this action in the given direction.
    def tilt_grid(%Grid2D.G{fields: fields, width: width, height: height}, next_mapper) do
      fields_to_tilt = for r <- 0..(height - 1), c <- 0..(width - 1), do: {r, c}

      {updated_fields, rolled_boulders} =
        Enum.reduce(fields_to_tilt, {fields, 0}, fn p, {acc, roll} ->
          value_at = Map.get(fields, p)
          value_next = Map.get(fields, next_mapper.(p))

          cond do
            # Found boulder at the edge of the grid, ignoring
            value_at == "O" and value_next == nil ->
              {acc, roll}

            # Found boulder blocked by another boulder or cube
            value_at == "O" and (value_next == "O" or value_next == "#") ->
              {acc, roll}

            # Found boulder with free path, moving to next position
            value_at == "O" ->
              {acc |> Map.put(p, ".") |> Map.put(next_mapper.(p), "O"), roll + 1}

            # Found cube or empty space, ignoring
            true ->
              {acc, roll}
          end
        end)

      new_grid = %Grid2D.G{fields: updated_fields, width: width, height: height}
      if rolled_boulders == 0, do: new_grid, else: tilt_grid(new_grid, next_mapper)
    end

    # Count the weight of the boulders on the northern support structure by mapping the grid
    # fields into a list of boulder coordinates and summing up their row value which is the
    # inverse of the row index.
    def northern_weight(%Grid2D.G{fields: fields, height: height}) do
      fields
      |> Enum.filter(fn {_, v} -> v == "O" end)
      |> Enum.map(fn {{r, _}, _} -> height - r end)
      |> Enum.sum()
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the weight of the boulders on the northern support strcuture by tilting the
    # grid to the north until all boulders have stopped rolling.
    def solve(input) do
      grid = Grid2D.new_from_input(input)

      grid
      |> tilt_grid(fn {r, c} -> {r - 1, c} end)
      |> northern_weight()
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    @iterations 1_000_000_000

    # We want to find the weight of the boulders on the northern support strcuture after `@iterations`
    # iterations by tilting the grid to the north/west/south/east on every iteration. Since actually
    # simulating this would take an awful lot of time, we instead figure out where the pattern first
    # starts to loop and then mathematically deduce the pattern which will be present after the last
    # iteration and calculate the weight from that.
    def solve(input) do
      grid = Grid2D.new_from_input(input)

      {first_occurrence, current_occurrence, patterns} = tilt_grid_to_loop(grid, [grid.fields])

      loop_size = current_occurrence - first_occurrence
      loop_range = @iterations - first_occurrence
      loop_rest = rem(loop_range, loop_size)

      final_fields = Enum.at(patterns, first_occurrence + loop_rest)

      northern_weight(Map.put(grid, :fields, final_fields))
    end

    # Tilt the grid until a loop is detected. This function takes the current grid, as well as a
    # list of patterns that have already occurred. On each iteration, it tilts the grid in all
    # four directions (north, west, south, east) and then compares if the resulting fields have
    # already occurred before.
    # If they have, we index the patterns and return the index of the first occurence, as well
    # as the current occurrence. This allows calculating the pattern at any future point.
    # If the pattern has not already occurred, we add it to the list and call ourselves again.
    defp tilt_grid_to_loop(grid, patterns) do
      tilted_grid =
        grid
        |> tilt_grid(fn {r, c} -> {r - 1, c} end)
        |> tilt_grid(fn {r, c} -> {r, c - 1} end)
        |> tilt_grid(fn {r, c} -> {r + 1, c} end)
        |> tilt_grid(fn {r, c} -> {r, c + 1} end)

      if tilted_grid.fields in patterns do
        indexed_patterns = patterns |> Enum.with_index()

        first_occurrence =
          indexed_patterns
          |> Enum.filter(fn {v, _} -> v == tilted_grid.fields end)
          |> Enum.at(0)
          |> elem(1)

        current_occurrence =
          indexed_patterns
          |> Enum.at(-1)
          |> elem(1)
          |> Kernel.+(1)

        {first_occurrence, current_occurrence, patterns ++ [tilted_grid.fields]}
      else
        tilt_grid_to_loop(tilted_grid, patterns ++ [tilted_grid.fields])
      end
    end
  end
end
