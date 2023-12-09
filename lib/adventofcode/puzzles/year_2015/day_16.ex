defmodule AdventOfCode.Puzzles.Year2015.Day16 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule Shared do
    # Ticker output manually copy/pasted and formatted from the puzzle text.
    @ticker_output %{
      "children" => 3,
      "cats" => 7,
      "samoyeds" => 2,
      "pomeranians" => 3,
      "akitas" => 0,
      "vizslas" => 0,
      "goldfish" => 5,
      "trees" => 3,
      "cars" => 2,
      "perfumes" => 1
    }

    # Parse the input by first splitting it by line, then adding an index starting at one,
    # which corresponds to the Sue's number, so we don't have to parse that. Afterwards,
    # we split each line further by `:` and `,`, discarding the first element, which is
    # the sue number and some text, chunk the data into pairs of two (which will always
    # be a property and its value) and then map these into a parsed `{k, v}` tuple.
    #
    # We return a tuple of the Sue's identifier (index) and her properties.
    def parse_input(input) do
      input
      |> Input.split_by_line(trim: true)
      |> Enum.with_index(1)
      |> Enum.map(fn {line, index} ->
        properties =
          line
          |> String.split([":", ","], trim: true)
          |> Enum.slice(1..-1)
          |> Enum.map(&String.trim/1)
          |> Enum.chunk_every(2)
          |> Enum.map(fn [k, v] -> {k, String.to_integer(v)} end)

        {index, properties}
      end)
    end

    # Get a specific value from the original ticker output in the puzzle description.
    def ticker_value(k), do: Map.get(@ticker_output, k)
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the number of the Sue that has sent us the letter.
    # To achieve this, we pass the list of sues through `sue_matches?/1`, which will check if
    # all given attributes match. We expect to end up with a single result of which we take the
    # first element of the tuple (the Sue number).
    def solve(input) do
      data = parse_input(input)

      data
      |> Enum.filter(&sue_matches?/1)
      |> Enum.at(0)
      |> elem(0)
    end

    # Check if all properties of a sue match the values given by the ticker.
    defp sue_matches?({_, props}), do: props |> Enum.all?(fn {k, v} -> ticker_value(k) == v end)
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the number of the Sue that has sent us the letter.
    # To achieve this, we still pass the list of sues through `sue_matches?/1`, which will check
    # if all given attributes either match or are less than (for cats and trees) or more than
    # (for pomeranians and goldfish) what is given in the ticker output.
    # Aside from the different `sue_matches?/1` filters, this is identical to part A.
    def solve(input) do
      data = parse_input(input)

      data
      |> Enum.filter(&sue_matches?/1)
      |> Enum.at(0)
      |> elem(0)
    end

    # Check if all properties of a sue match the values given by the ticker or are
    # less than (for cats and trees) or more than (for pomeranians and goldfish) what
    # is given in the ticker output, as requested by the puzzle output
    defp sue_matches?({_, props}) do
      props
      |> Enum.all?(fn
        {k, v} when k in ["cats", "trees"] -> v > ticker_value(k)
        {k, v} when k in ["pomeranians", "goldfish"] -> v < ticker_value(k)
        {k, v} -> ticker_value(k) == v
      end)
    end
  end
end
