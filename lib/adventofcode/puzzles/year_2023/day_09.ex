defmodule AdventOfCode.Puzzles.Year2023.Day09 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule Shared do
    # Parse the input by splitting it at newlines and then splitting those at whitespaces,
    # converting the resulting chunks into integers, so that we end up with a list of lists
    # of numbuers, corresponding to the measured data.
    def parse_input(input) do
      input
      |> Input.split_by_line(trim: true)
      |> Input.split_by_char(" ", trim: true)
      |> Enum.map(fn line ->
        line |> Enum.map(&String.to_integer/1)
      end)
    end

    # Expand the virtual "number pyramid" that we are building by one layer by grouping the
    # most recent layer into chunks of two, calculating their difference and storing this
    # new layer with n-1 numbers as the new most recent one.
    # The difference between the two numbers in a chunk is calculated as `b - a`, which is
    # the actual change in value between the steps, NOT the absolute difference between them!
    def expand([h | _] = lists) do
      if Enum.all?(h, &(&1 == 0)), do: lists, else: expand([expand_map(h) | lists])
    end

    def expand_map(list) do
      list
      |> Enum.chunk_every(2, 1)
      |> Enum.filter(fn l -> Enum.count(l) == 2 end)
      |> Enum.map(fn [a, b] -> b - a end)
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the next predicted number for each sequence of measurements. To do so, we
    # essentially build a virtual number pyramid by reducing each sequence of measurements into
    # a list of differences between measurements until we reach an "all-zero" difference and then
    # using this to extrapolate from the bottom up again, finding the next number.
    def solve(input) do
      data = parse_input(input)

      data
      |> Enum.map(fn line ->
        [line]
        |> expand()
        |> extrapolate()
      end)
      |> Enum.sum()
    end

    # To extrapolate, remove the first (shortest, intially all-zero) line from the pyramid and
    # expand the second line with the sum of its last value and the last value in the first line.
    # We repeat this until we have reached the last line (the initial input), at which point we
    # return the last value in that list, which has now been extrapolated as described above.
    defp extrapolate([a]), do: Enum.at(a, -1)

    defp extrapolate([a, b | t]) do
      new_b = b ++ [Enum.at(b, -1) + Enum.at(a, -1)]
      extrapolate([new_b | t])
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to essentially do the same as in part A but instead of finding the next number in
    # the sequence, we want to find the previous number in each sequence. To do this, we parse
    # and expand each sequence the same as in part A but then use a different extrapolate
    # function that looks at the first values in each level of the pyramid instead of the last.
    def solve(input) do
      data = parse_input(input)

      data
      |> Enum.map(fn line ->
        [line]
        |> expand()
        |> extrapolate()
      end)
      |> Enum.sum()
    end

    # To extrapolate, remove the first (shortest, intially all-zero) line from the pyramid and
    # expand the second line with the sum of its first value and the first value in the first line.
    # We repeat this until we have reached the last line (the initial input), at which point we
    # return the first value in that list, which has now been extrapolated as described above.
    defp extrapolate([a]), do: Enum.at(a, 0)

    defp extrapolate([a, b | t]) do
      new_b = [Enum.at(b, 0) - Enum.at(a, 0)] ++ b
      extrapolate([new_b | t])
    end
  end
end
