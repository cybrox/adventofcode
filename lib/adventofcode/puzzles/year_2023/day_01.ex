defmodule AdventOfCode.Puzzles.Year2023.Day01 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule PartA do
    @numbers 0..9 |> Enum.map(&Integer.to_string/1)

    # We want to find the sum of numbers in the calibration document where each number
    # is defined by the first and last numeric digit on a line in the document.
    # To achieve this, we read the document line by line, filter out all the characters
    # that are digits and then sum them up using `(10*first + last)` to get a two-digit number.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Input.split_by_char("", trim: true)

      Enum.reduce(data, 0, fn line, acc -> evaluate_line(line, acc) end)
    end

    # Evaluate a single line by filtering its char array for valid digit characters
    # and then adding the first*10 and the last digit to the accumulator.
    defp evaluate_line(line, acc) do
      numbers =
        line
        |> Enum.filter(&(&1 in @numbers))
        |> Enum.map(&String.to_integer/1)

      acc + (List.first(numbers) * 10 + List.last(numbers))
    end
  end

  defmodule PartB do
    @number_names ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    @digit_map 0..9 |> Enum.map(&{Integer.to_string(&1), &1})
    @named_map 0..9 |> Enum.map(&{Enum.at(@number_names, &1), &1})

    # We want to find the sum of numbers in the calibration document where each number
    # is defined by the first and last numeric or written digit on a line in the document.
    # The tricky part here is that written segments can overlap and the puzzle expects
    # us to pick the first leading and the last trailing one. So `oneighthreeight` is `18`.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)

      Enum.reduce(data, 0, fn line, acc -> evaluate_line(line, acc) end)
    end

    # Evaluate a single line by finding the indices of all digit numbers (`0` - `9`) as well
    # as all named numbers (`zero` - `nine`), sorting it incrementally by index in the line
    # and then adding the first*10 and the last digit to the accumulator.
    defp evaluate_line(line, acc) do
      digit_numbers = find_chunk_indices(line, @digit_map)
      named_numbers = find_chunk_indices(line, @named_map)

      all_numbers =
        (digit_numbers ++ named_numbers)
        |> Enum.sort_by(fn {_, i} -> i end)
        |> Enum.map(fn {n, _} -> n end)

      acc + (List.first(all_numbers) * 10 + List.last(all_numbers))
    end

    # Find the indices of a given list of chunks in a line. This expects a list of chunks in
    # the form `[{match, result}, {match, result}, ...]` and will iterate through those.
    # It will return a list of indices where `match` was found tupled with `result`
    defp find_chunk_indices(line, chunks) do
      chunks
      |> Enum.map(&mapped_binary_match(line, &1))
      |> List.flatten()
    end

    # A wrapper for `:binary.matches/2` where matches are tupled with `result` instead of size
    defp mapped_binary_match(line, {match, result}),
      do: :binary.matches(line, match) |> Enum.map(fn {i, _} -> {result, i} end)
  end
end
