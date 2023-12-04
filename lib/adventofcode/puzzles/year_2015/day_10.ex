defmodule AdventOfCode.Puzzles.Year2015.Day10 do
  require Logger

  alias AdventOfCode.Common.Input
  alias AdventOfCode.Common.Util

  defmodule Shared do
    # Read the input, split it into a list of number strings, map each into an actual
    # number and then apply `look_and_say/2` for `iteration` iterations and count the
    # numbers in te resulting list.
    def solve(input, iterations) do
      input
      |> Input.clean_trim()
      |> Input.split_by_char("", trim: true)
      |> Enum.map(&Util.str2int/1)
      |> look_and_say(iterations, 0)
      |> Enum.count()
    end

    # Perform the look and say game on a sequence of numbers. This expects a flat list
    # of numbers and will chunk them every time the value changes. Then it maps each chunk
    # into a list of `[l, n]` where `l` is the length of the chunk (e.g. how often the number
    # occurs) and `n` is the actual value of the number. This is one cycle of the game.
    # We then perform this recursively until the desired number of iterations is reached.
    def look_and_say(list, times, i) when times == i, do: list

    def look_and_say(list, times, i) do
      list
      |> Enum.chunk_by(& &1)
      |> Enum.map(&look_at/1)
      |> List.flatten()
      |> look_and_say(times, i + 1)
    end

    # Look at a single chunk of numbers in the format `[n]`, `[n, n]`, etc. and convert it
    # into a new list of two numbers where the first is the amount of items in the original
    # list and the second one is the value in the original list.
    def look_at([n]), do: [1, n]
    def look_at([n | _t] = all), do: [Enum.count(all), n]
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    @iterations 40

    # We want to find the result of applying the look-and-say game algorithm to the input 40
    # times. Since the solutions are identical, this just calles a shared `solve/2`.
    # See: https://en.wikipedia.org/wiki/Look-and-say_sequence
    def solve(input), do: solve(input, @iterations)
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    @iterations 50

    # We want to find the result of applying the look-and-say game algorithm to the input 40
    # times. Since the solutions are identical, this just calles a shared `solve/2`.
    # See: https://en.wikipedia.org/wiki/Look-and-say_sequence
    def solve(input), do: solve(input, @iterations)
  end
end
