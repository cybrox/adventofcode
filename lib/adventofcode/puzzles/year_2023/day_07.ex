defmodule AdventOfCode.Puzzles.Year2023.Day07 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule PartA do
    # We want to find out the total score of our hands. The score of a hand is defined by its
    # bid multiplied with its rank amongst all scores, where the highest scoring hand has the
    # highest rank. To do this, we first map our input data into a tuple of `{cards, bid}` where
    # `cards` is a list of cards in our hand (in order) and `bid` is the bid for that hand.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Input.split_by_char(" ", trim: true)
        |> Enum.map(fn [a, b] -> {String.split(a, "", trim: true), String.to_integer(b)} end)

      # We map the list of `{hand, bid}` tuples into a list of `{strength, hand, bid}` tuples,
      # where `strength` is a numeric value representing the strength of a hand.
      # Afterwards, we sort this list using a mapper that maps the input tuple into a
      # `{strength, values}` tuple,  where values is all cards mapped to their individual scores.
      # Since Elixir will sort tuples and lists in order, this will give us all hands sorted by
      # their strength and then by their individual card's strength.
      # Once we have the sorted list, we add an index starting at 1 to each so we get a
      # `{data, rank}` tuple, which we than map to `data.bid * rank` and sum them up.
      data
      |> Enum.map(fn {hand, bid} -> {hand_strength(hand), hand, bid} end)
      |> Enum.sort_by(fn {strength, hand, _} ->
        {strength, Enum.map(hand, fn card -> card_strength(card) end)}
      end)
      |> Enum.with_index(1)
      |> Enum.map(fn {{_, _, bid}, rank} -> bid * rank end)
      |> Enum.sum()
    end

    # Get the strength of a hand of cards from its list of cards.
    # This is done by using `Enum.frequencies/1` to get the amount of pairs, triplets, etc.
    # in the hand and assigning the hand a score based on the number of combinations
    defp hand_strength(list) do
      groups =
        list
        |> Enum.frequencies()
        |> Enum.map(fn {_, n} -> n end)
        |> Enum.sort()

      case groups do
        [1, 1, 1, 1, 1] -> 0
        [1, 1, 1, 2] -> 1
        [1, 2, 2] -> 2
        [1, 1, 3] -> 4
        [2, 3] -> 5
        [1, 4] -> 6
        [5] -> 7
      end
    end

    # Get the individual strength of a card as defined by the puzzle
    defp card_strength("A"), do: 14
    defp card_strength("K"), do: 13
    defp card_strength("Q"), do: 12
    defp card_strength("J"), do: 11
    defp card_strength("T"), do: 10
    defp card_strength(n), do: String.to_integer(n)
  end

  defmodule PartB do
    # We want to find out the total score of our hands. The score of a hand is defined by its
    # bid multiplied with its rank amongst all scores, where the highest scoring hand has the
    # highest rank. To do this, we first map our input data into a tuple of `{cards, bid}` where
    # `cards` is a list of cards in our hand (in order) and `bid` is the bid for that hand.
    # In this part `J` has the lowest value (`1`) but can influence the `hand_strength/1`.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Input.split_by_char(" ", trim: true)
        |> Enum.map(fn [a, b] -> {String.split(a, "", trim: true), String.to_integer(b)} end)

      # The sorting and accumulating works exactly the same as in part A.
      data
      |> Enum.map(fn {hand, bid} -> {hand_strength(hand), hand, bid} end)
      |> Enum.sort_by(fn {strength, hand, _} ->
        {strength, Enum.map(hand, fn card -> card_strength(card) end)}
      end)
      |> Enum.with_index(1)
      |> Enum.map(fn {{_, _, bid}, rank} -> bid * rank end)
      |> Enum.sum()
    end

    # Get the strength of a hand of cards from its list of cards.
    # This works the same as in part A but instead of directly checking the list of frequencies,
    # we first attempt to find the best hand based on the number of jokers in the hand.
    defp hand_strength(list) do
      groups = list |> Enum.frequencies()
      frequencies = groups |> Enum.map(fn {_, n} -> n end) |> Enum.sort()
      jokers = groups |> Enum.into(%{}) |> Map.get("J", 0)

      best_hand = best_hand_for(frequencies, jokers)

      case best_hand do
        [1, 1, 1, 1, 1] -> 0
        [1, 1, 1, 2] -> 1
        [1, 2, 2] -> 2
        [1, 1, 3] -> 4
        [2, 3] -> 5
        [1, 4] -> 6
        [5] -> 7
      end
    end

    # Get the best hand for a list of frequencies and a number of jokers.
    # This only covers cases that are possible. For example, if there are 3 jokers,
    # the card distribution must be either `3/2` or `3/1/1`.
    defp best_hand_for(freq, 0), do: freq
    defp best_hand_for([1, 1, 1, 1, 1], 1), do: [1, 1, 1, 2]
    defp best_hand_for([1, 1, 1, 2], 1), do: [1, 1, 3]
    defp best_hand_for([1, 2, 2], 1), do: [2, 3]
    defp best_hand_for([1, 1, 3], 1), do: [1, 4]
    defp best_hand_for([2, 3], 1), do: [1, 4]
    defp best_hand_for([1, 4], 1), do: [5]
    defp best_hand_for([5], 1), do: [5]
    defp best_hand_for([1, 1, 1, 2], 2), do: [1, 1, 3]
    defp best_hand_for([1, 2, 2], 2), do: [1, 4]
    defp best_hand_for([2, 3], 2), do: [5]
    defp best_hand_for([1, 1, 3], 3), do: [1, 4]
    defp best_hand_for([2, 3], 3), do: [5]
    defp best_hand_for([1, 4], 4), do: [5]
    defp best_hand_for([5], 5), do: [5]

    # Get the individual strength of a card as defined by the puzzle
    defp card_strength("A"), do: 14
    defp card_strength("K"), do: 13
    defp card_strength("Q"), do: 12
    defp card_strength("J"), do: 1
    defp card_strength("T"), do: 10
    defp card_strength(n), do: String.to_integer(n)
  end
end
