defmodule AdventOfCode.Puzzles.Year2015.Day04 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule PartA do
    # We want to find the first hash that starts with five zeroes based on an input
    # consisting of our seed (puzzle input) and an incrementing number
    def solve(input) do
      data =
        input
        |> Input.clean_trim()

      find_first_match(data)
    end

    # Iterate by incrementing an iterator endlesssly until the generated value
    # matches the expected test criteria checked by `matches_goal?/2`.
    defp find_first_match(seed, i \\ 0) do
      if matches_goal?("#{seed}#{i}"), do: i, else: find_first_match(seed, i + 1)
    end

    # MD5 hash a generated input and return whether it starts with 5 zeroes
    defp matches_goal?(input), do: md5_hash(input) |> String.starts_with?("00000")

    # MD5 hash an input and return it encoded in Base64
    defp md5_hash(input), do: :crypto.hash(:md5, input) |> Base.encode16()
  end

  defmodule PartB do
    # We want to find the first hash that starts with six zeroes based on an input
    # consisting of our seed (puzzle input) and an incrementing number
    def solve(input) do
      data =
        input
        |> Input.clean_trim()

      find_first_match(data)
    end

    # Iterate by incrementing an iterator endlesssly until the generated value
    # matches the expected test criteria checked by `matches_goal?/2`.
    defp find_first_match(seed, i \\ 0) do
      if matches_goal?("#{seed}#{i}"), do: i, else: find_first_match(seed, i + 1)
    end

    # MD5 hash a generated input and return whether it starts with 6 zeroes
    defp matches_goal?(input), do: md5_hash(input) |> String.starts_with?("000000")

    # MD5 hash an input and return it encoded in Base64
    defp md5_hash(input), do: :crypto.hash(:md5, input) |> Base.encode16()
  end
end
