defmodule AdventOfCode.Puzzles.Year2015.Day14 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule Shared do
    @input_splits [" can fly ", " km/s for ", " seconds, but then must rest for ", " seconds"]

    # Parse the input by first splitting it into a list of lines and then splitting each line
    # by the segments in `@input_splits` to get only the data we want. With integer parsing, we
    # return a tuple of `{name, speed, runtime, resttime}` where `name` is the name of the
    # reindeer, `speed` is its running speed, `runtime` is the time it can run and `resttime` is
    # the time it needs to rest after each running burst.
    def parse_input(input) do
      input
      |> Input.split_by_line(trim: true)
      |> Enum.map(fn line ->
        [name, speed, runtime, resttime, _] = line |> String.split(@input_splits)

        {
          name,
          String.to_integer(speed),
          String.to_integer(runtime),
          String.to_integer(resttime)
        }
      end)
    end

    # Get the score of a reindeer after a specific number of seconds. To calculate this, we first
    # calculate the time each reindeer needs for one run + sleep cycle, as well as the distance
    # it travels. We then calculate the number of full cycles it completed in the given time,
    # as well as the remaining seconds.
    # We return a tuple of `{name, dist}` where `name` is the name of the reindeer and `dist`
    # is the total distance travelled, which includes potential incomplete cycles.
    def get_score({name, speed, runtime, resttime}, after_second) do
      cycle_distance = speed * runtime
      cycle_time = runtime + resttime

      full_cycles = div(after_second, cycle_time)
      rem_seconds = rem(after_second, cycle_time)

      {name, full_cycles * cycle_distance + min(rem_seconds, runtime) * speed}
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    @race_time 2503

    # We want to find the farthest a reindeer has travelled after a given number of seconds.
    # To do so, we parse the input into a list of reindeer information tuples and then map
    # these into their distance for the given race time. Then get the maximum distance.
    def solve(input) do
      data = parse_input(input)

      data
      |> Enum.map(&get_score(&1, @race_time))
      |> Enum.map(fn {_, v} -> v end)
      |> Enum.max()
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    @race_time 2503

    # With the changed scoring, we want to find the reindeer(s) that are currently ahead at
    # each second of the race and award those a point. In the end, we want to find out what
    # the maximum number of points awarded to any reindeer is.
    #
    # [!] An iterative solution would be more efficient for this but in "wise" foresight,
    # I chose a mathematical solution for part A, because Advent of Code often uses a very
    # high number in part B to discourage iterative brute forcing. Well, not this time...
    # Since I'm too lazy to completely rewrite my solution, we find the max. number of
    # stars awarded to any reindeer by simply running the `get_score/2` function for each
    # second in the race, accumulatin the winners into a list, then getting their frequencies
    # and selecting the maximum of those.
    def solve(input) do
      data = parse_input(input)

      Enum.reduce(1..@race_time, [], fn sec, acc ->
        scores = data |> Enum.map(&get_score(&1, sec))
        best = scores |> Enum.map(fn {_, v} -> v end) |> Enum.max()
        wins = scores |> Enum.filter(fn {_, v} -> v == best end) |> Enum.map(fn {k, _} -> k end)

        wins ++ acc
      end)
      |> Enum.frequencies()
      |> Enum.map(fn {_, v} -> v end)
      |> Enum.max()
    end
  end
end
