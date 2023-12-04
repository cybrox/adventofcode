defmodule AdventOfCode.Puzzles.Year2023.Day04 do
  require Logger

  alias AdventOfCode.Common.Input
  alias AdventOfCode.Common.Util

  defmodule Shared do
    # Parse a single line of the input into a tuple containing the card number
    # as well as a list of winning and a list of having numbers as integers.
    def parse_line(line) do
      [<<"Card ", card_id::binary>>, winning, have] =
        String.split(line, [":", "|"], trim: true, parts: 3)

      {Util.str2int(card_id), parse_numbers(winning), parse_numbers(have)}
    end

    # Parse a textual list of numbers into an actual list of numbers by splitting it at every
    # whitespace (` `), trimming the segments and then converting them to integers.
    def parse_numbers(numbers) do
      numbers
      |> String.split(" ", trim: true)
      |> Enum.map(&Util.str2int/1)
    end

    # Convert a list of `{card_id, winning, having}` into a list of `{card_id, overlapping}`
    # tuples, where `overlapping` is the number of overlapping numbers between the winning
    # and having list (e.g. the numbers that we actually won)
    def find_overlaps(list) do
      Enum.map(list, fn {card_id, winning, having} ->
        overlapping = having |> Enum.filter(&(&1 in winning)) |> Enum.count()
        {card_id, overlapping}
      end)
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the score of all scratch cards where we have some numbers on
    # the having side that are also listed on the winning side. Each card counts
    # for `2^n` points, where n is the number of matching (winning/having) numbers.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(&parse_line/1)
        |> find_overlaps()

      # Calculate the total score by mapping each tuple to the power of two to the
      # number of matching winning/having numbers (minus one to account for 2^0)
      # and then summing them up to get the total score.
      data
      |> Enum.map(fn {_card_id, overlapping} -> floor(:math.pow(2, overlapping - 1)) end)
      |> Enum.sum()
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to get the total number of scratch cards that we get, assuming that each cards
    # number of winning number instructs us to take the subsequent `n` cards and perform the
    # evaluation for these again recursively.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(&parse_line/1)
        |> find_overlaps()

      # Reduce the winning cards into a sum of total scratch cards that we obtained
      # We start the accumulator with the number of items in the original list of
      # scratch cards, so that these are accounted for.
      reduce_winning(data, data, Enum.count(data))
    end

    # Reduce the winning cards by mapping each card in the list to another run of
    # `reduce_winning/3` with the new subsequent list to work through.
    #
    # This takes the list of all cards that we need for lookups as first argument.
    # That list will remain unchanged throughout all loops. The second argument is
    # the list of cards to look through. Initially, this is all cards but as
    # we recursively reach cards that have no winning numbers (e.g. no subsequent)
    # cards to evaluate, this will trend towards `[]` where that branch of the
    # recursion will then end.
    #
    # The last parameter is the accumulator which counts the total number of cards
    # that have been evaluated. This starts at the number of input cards.
    defp reduce_winning(_all_cards, [], acc), do: acc

    defp reduce_winning(all_cards, to_scratch, acc) do
      subsequent_cards =
        to_scratch
        |> Enum.map(fn {i, n} -> Enum.slice(all_cards, i, n) end)
        |> List.flatten()

      reduce_winning(all_cards, subsequent_cards, acc + Enum.count(subsequent_cards))
    end
  end
end
