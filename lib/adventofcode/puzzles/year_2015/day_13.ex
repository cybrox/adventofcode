defmodule AdventOfCode.Puzzles.Year2015.Day13 do
  require Logger

  alias AdventOfCode.Common.Input
  alias AdventOfCode.Common.Util

  defmodule Shared do
    @input_splits [" would ", " happiness units by sitting next to ", "."]

    # Parse the input by splitting it into separate lines and then splitting these by
    # `@input_splits` to obtain a list of person A, their happiness score, person B and
    # an unused dot at the end.
    # We then genereate a happiness lookup table of `{a, b} -> s` where `a` and `b` are
    # people and `s` is their relative happiness score, as well as a list of all people
    # derived from the list of happiness scores.
    # We return a tuple of `{happiness_lookup, people}` for further solving
    def parse_input(input) do
      happiness_data =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(fn line ->
          [a, score, b, _] = String.split(line, @input_splits, parts: 4)
          {{a, b}, parse_score(score)}
        end)

      happiness_lookup =
        happiness_data
        |> List.flatten()
        |> Enum.into(%{})

      people =
        happiness_data
        |> Enum.map(fn {{a, b}, _} -> [a, b] end)
        |> List.flatten()
        |> Enum.uniq()

      {people, happiness_lookup}
    end

    # Parse a happiness score. The "gain" and "lose" keyword define the polarity of happiness.
    defp parse_score(<<"gain ", n::binary>>), do: String.to_integer(n)
    defp parse_score(<<"lose ", n::binary>>), do: String.to_integer(n) * -1
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the best possible seating order with the maximum happiness change.
    # This is essentially an inverted travelling salesman problem (TSP)
    # See: https://en.wikipedia.org/wiki/Travelling_salesman_problem
    #
    # To solve this, we first get all possible permutations (seating orders) and then
    # evaluate each of them by chunking it into a list of tuples of two people and
    # looking up their happiness relationship. We then sum up these chunks and pick
    # the best possible happiness score change.
    def solve(input) do
      {people, happiness_lookup} = parse_input(input)

      people
      |> Util.permutations_of()
      |> Enum.map(fn arrangement ->
        arrangement
        |> Enum.chunk_every(2, 1, [Enum.at(arrangement, 0)])
        |> Enum.map(fn [a, b] -> [{a, b}, {b, a}] end)
        |> List.flatten()
        |> Enum.uniq()
        |> Enum.map(fn k -> Map.get(happiness_lookup, k) end)
        |> Enum.sum()
      end)
      |> Enum.max()
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the best possible seating order with the maximum happiness change.
    # The only difference to part A is that we now include ourselves in the calculation.
    #
    # To solve this, we add `"Me"` to the list of people before generating all possible
    # permutations and simply return `0` for any unknown happiness lookup, since all the
    # other people have a score assigned and ours is intended to be zero.
    def solve(input) do
      {people, happiness_lookup} = parse_input(input)

      ["Me" | people]
      |> Util.permutations_of()
      |> Enum.map(fn arrangement ->
        arrangement
        |> Enum.chunk_every(2, 1, [Enum.at(arrangement, 0)])
        |> Enum.map(fn [a, b] -> [{a, b}, {b, a}] end)
        |> List.flatten()
        |> Enum.uniq()
        |> Enum.map(fn k -> Map.get(happiness_lookup, k, 0) end)
        |> Enum.sum()
      end)
      |> Enum.max()
    end
  end
end
