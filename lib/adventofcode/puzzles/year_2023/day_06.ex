defmodule AdventOfCode.Puzzles.Year2023.Day06 do
  require Logger

  alias AdventOfCode.Common.Input
  alias AdventOfCode.Common.Util

  defmodule Shared do
    # Given a round with duration `duration` and record `record`, find the first `i` where
    # that record is broken. Each iteration, `i` is changed by `iterator.(i)`, so it is
    # possible to use `&(&+1)` or `&(&-1)` as iterators for searching from both sides.
    def find_record_for(i, duration, record, iterator) do
      if get_round_time(i, duration) <= record,
        do: find_record_for(iterator.(i), duration, record, iterator),
        else: i
    end

    # Get the race time for a single round from the winding time `wind` and the total
    # round time `total` by counting winding ms as 0 and the remainder as `n * wind`ms
    defp get_round_time(wind, total), do: (total - wind) * wind
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the product of the number of possible record times for each race.
    # We do this by parsing the input into a list of tuples of `{race_time, race_record}`
    # and then mapping those to get the first and last possible record. The difference
    # between these is the number of possible records.
    def solve(input) do
      input
      |> Input.split_by_line(trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split(" ", trim: true)
        |> Enum.slice(1..-1)
        |> Enum.map(&Util.str2int/1)
      end)
      |> Enum.zip()
      |> Enum.map(fn {duration, record} ->
        first_record = find_record_for(0, duration, record, &(&1 + 1))
        last_record = find_record_for(duration, duration, record, &(&1 - 1))

        last_record - first_record + 1
      end)
      |> Enum.product()
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the total number of possible record times, assuming the input is not
    # a list but instead a single number with odd spaces between the digits. To achieve this,
    # instead of mapping to a list of tuples, we simply map the two lines into two integers
    # and then run the record finding once for this pair of `duration`/`record` information.
    def solve(input) do
      [duration, record] =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split(" ", trim: true)
          |> Enum.slice(1..-1)
          |> Enum.join()
        end)
        |> Enum.map(&Util.str2int/1)

      first_record = find_record_for(0, duration, record, &(&1 + 1))
      last_record = find_record_for(duration, duration, record, &(&1 - 1))

      last_record - first_record + 1
    end
  end
end
