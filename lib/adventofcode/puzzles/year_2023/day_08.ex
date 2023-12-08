defmodule AdventOfCode.Puzzles.Year2023.Day08 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule Shared do
    # Parse the input data by first splitting it by the empty newline into move and
    # node instructions. The move instructions are then simply split into a list of
    # characters (`L` or `R`) while the node instructions are split using binary pattern
    # matching into `{node, {l-target, r-target}}`, which are then mapped into a map, so
    # that we have a lookup table of `node => {l-target, r-target}`.
    def parse_input(input) do
      [move_data, node_data] =
        input
        |> Input.split_by_char("\n\n", trim: true)

      moves = Input.split_by_char(move_data, "", trim: true)

      nodes =
        node_data
        |> Input.split_by_line(trim: true)
        |> Enum.map(fn <<
                         t::binary-size(3),
                         " = (",
                         l::binary-size(3),
                         ", ",
                         r::binary-size(3),
                         ")"
                       >> ->
          {t, {l, r}}
        end)
        |> Enum.into(%{})

      {moves, nodes}
    end

    # Get the next index to read from the moves list. This implements a simple overflow,
    # so that the index pointer can start from the beginning of the moves list again.
    def next_index(moves, index) do
      if index < Enum.count(moves) - 1, do: index + 1, else: 0
    end

    # Get the diraction to take from the nodes lookup table, given the current node and a
    # direction which can be `L` or `R`. Takes advantage of the previously mapped data.
    def get_direction(nodes, current, "L"), do: Map.get(nodes, current) |> elem(0)
    def get_direction(nodes, current, "R"), do: Map.get(nodes, current) |> elem(1)
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the number of moves it will take us to reach the node `ZZZ` starting
    # at the node `AAA`. To do this, we simply traverse the desert using our directions.
    def solve(input) do
      {moves, nodes} = parse_input(input)
      traverse(moves, nodes, "AAA", 0, 0)
    end

    # Traverse a single step. This takes the list of moves `moves`, the node lookup table `nodes`,
    # the current node we're on, as well as the current index `index` of the move list that we are
    # looking at and an accumulator `acc`.
    # Once we reached `ZZZ`, we return the accumulator.
    # Otherwise, we get the direction from the current node based on the lookup table and
    # then recrusively call `traverse/5` again, incrementing the accumulator by one.
    defp traverse(_moves, _nodes, "ZZZ", _index, acc), do: acc

    defp traverse(moves, nodes, current, index, acc) do
      next_current = get_direction(nodes, current, Enum.at(moves, index))
      traverse(moves, nodes, next_current, next_index(moves, index), acc + 1)
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the number of moves it will take us to reach the node `??Z` starting
    # at the node `??A`. To do this, we need to "simultanously traverse from each `??A`
    # node to each `??Z` node until we have reached all nodes ending in `Z` at the same time.
    #
    # We first find a list of start nodes, since now we're starting at every node ending in
    # `A` (e.g. `XXA`) instead of just `AAA`. Instead of actually simultanously traversing
    # the desert, we simply map each `start_node` into `steps_needed` by calling `traverse/5`
    # just like in part A. (Except the end condition for that function differs a bit).
    #
    # Once we have a list of all the steps needed for each starting point to reach its end
    # point, we simply calculate the least common multiple (LCM) of those numbers
    def solve(input) do
      {moves, nodes} = parse_input(input)

      steps_needed =
        nodes
        |> Enum.map(fn {name, _} -> name end)
        |> Enum.filter(&String.ends_with?(&1, "A"))
        |> Enum.map(fn start_node ->
          traverse(moves, nodes, start_node, 0, 0)
        end)

      # I need to learn how to properly calculate LCM
      [largest | rest] = Enum.sort(steps_needed, :desc)
      lcm_for(largest, rest, 1)
    end

    # "Brute-force" calculation of the LCM based on the biggest number
    # TODO: Add math library with prime based LCM.
    defp lcm_for(largest, rest, times) do
      if Enum.all?(rest, fn r -> rem(largest * times, r) == 0 end) do
        largest * times
      else
        lcm_for(largest, rest, times + 1)
      end
    end

    # Traverse a single step. This takes the list of moves `moves`, the node lookup table `nodes`,
    # the current node we're on, as well as the current index `index` of the move list that we are
    # looking at and an accumulator `acc`.
    # Once we reached any node ending in `Z` (e.g. `XXZ`), we return the accumulator.
    # Otherwise, we get the direction from the current node based on the lookup table and
    # then recrusively call `traverse/5` again, incrementing the accumulator by one.
    defp traverse(_moves, _nodes, <<_::binary-size(2), "Z">>, _index, acc), do: acc

    defp traverse(moves, nodes, current, index, acc) do
      next_current = get_direction(nodes, current, Enum.at(moves, index))
      traverse(moves, nodes, next_current, next_index(moves, index), acc + 1)
    end
  end
end
