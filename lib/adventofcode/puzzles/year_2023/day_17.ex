defmodule AdventOfCode.Puzzles.Year2023.Day17 do
  require Logger

  alias AdventOfCode.Common.Grid2D

  defmodule PartA do
    def solve(input) do
      grid = Grid2D.new_from_input(input, &String.to_integer/1)
      goal = {grid.height - 1, grid.width - 1}

      # open_set = grid.fields |> Enum.map(fn {p, c} -> {p, c} end)
      # open_set = [{{0, 0}, :right, 0}, 0}]

      # {post, dir, steps} -> {cost, visited, parent}
      heur = Grid2D.mh_distance({0, 0}, goal)
      open_set = [{{{0, 0}, :right, 0}, {0, nil, heur}}] |> Enum.into(%{})

      dijkstra(grid, open_set, %{}, goal)
    end

    defp dijkstra(grid, open_set, closed_set, goal) do
      # Get the node with the currently lowest cost
      {{current_pos, current_dir, current_n} = current_key,
       {current_cost, current_parent, current_heur}} =
        lowest_cost(open_set)

      last_pos =
        case current_parent do
          nil -> nil
          {any, _, _} -> any
        end

      # Mark our own node as visited.
      # open_set = Map.put(open_set, current_key, {current_cost, true, current_parent})
      open_set = Map.delete(open_set, current_key)
      closed_set = Map.put(closed_set, current_key, {current_cost, current_parent, current_heur})

      # Check if we have reached foal
      if current_pos == goal do
        {hit_at, _} =
          closed_set |> Map.filter(fn {{p, _, _}, _} -> p == goal end) |> Enum.at(0)

        visited = backtrack(closed_set, hit_at, [])
        dbg(visited)
        hits = visited |> Enum.map(fn {p, _, _} -> p end)

        dbg_fields =
          grid.fields
          |> Enum.map(fn {k, v} ->
            if k in hits, do: {k, 0}, else: {k, v}
          end)

        Grid2D.debug_print(%{grid | fields: dbg_fields})

        cost = hits |> Enum.map(fn p -> Grid2D.get(grid, p) end) |> Enum.sum()
        dbg(cost - Grid2D.get(grid, {0, 0}))

        raise "done"
      end

      # Get all possible neighbours for the node
      possible_neighbours =
        Grid2D.adjecant_of(grid, current_pos)
        |> Enum.filter(fn p -> p != {:error, :outside} and p != last_pos end)
        |> Enum.map(fn p ->
          new_dir = dir_for(current_pos, p)
          new_n = if current_dir == new_dir, do: current_n + 1, else: 1
          heur = Grid2D.mh_distance(p, goal)
          {{p, new_dir, new_n}, {current_cost + Grid2D.get(grid, p), current_key, heur}}
        end)
        |> Enum.filter(fn {{_, _, n} = k, _} -> n <= 3 and !Map.has_key?(closed_set, k) end)

      open_set =
        Enum.reduce(possible_neighbours, open_set, fn {k, v}, acc ->
          Map.update(acc, k, v, fn old_v ->
            {old_cost, _, _} = old_v
            {cost, _, _} = v
            if cost < old_cost, do: v, else: old_v
          end)
        end)

      dijkstra(grid, open_set, closed_set, goal)
    end

    defp lowest_cost(set),
      do:
        set
        |> Enum.sort_by(fn {_, {c, _, h}} -> c + h end)
        |> Enum.at(0)

    defp dir_for({ra, ca}, {rb, cb}) do
      cond do
        ra == rb and ca < cb -> :right
        ra == rb and ca > cb -> :left
        ca == cb and ra < rb -> :down
        ca == cb and ra > rb -> :up
      end
    end

    defp backtrack(_set, nil, acc), do: acc

    defp backtrack(set, pos, acc) do
      backtrack(set, Map.get(set, pos) |> elem(1), [pos | acc])
    end
  end

  defmodule PartB do
    def solve(input) do
      grid = Grid2D.new_from_input(input, &String.to_integer/1)
      goal = {grid.height - 1, grid.width - 1}

      # open_set = grid.fields |> Enum.map(fn {p, c} -> {p, c} end)
      # open_set = [{{0, 0}, :right, 0}, 0}]

      # {post, dir, steps} -> {cost, visited, parent}
      heur = Grid2D.mh_distance({0, 0}, goal)
      open_set = [{{{0, 0}, :still, 0}, {0, nil, heur}}] |> Enum.into(%{})

      dijkstra(grid, open_set, %{}, goal)
    end

    defp dijkstra(grid, open_set, closed_set, goal) do
      # Get the node with the currently lowest cost
      # dbg(open_set)
      # dbg(lowest_cost(open_set))

      {{current_pos, current_dir, current_n} = current_key,
       {current_cost, current_parent, current_heur}} =
        lowest_cost(open_set)

      # Mark our own node as visited.
      # open_set = Map.put(open_set, current_key, {current_cost, true, current_parent})
      open_set = Map.delete(open_set, current_key)
      closed_set = Map.put(closed_set, current_key, {current_cost, current_parent, current_heur})

      # Check if we have reached foal
      if current_pos == goal do
        {hit_at, _} =
          closed_set |> Map.filter(fn {{p, _, _}, _} -> p == goal end) |> Enum.at(0)

        hits = backtrack(closed_set, hit_at, [])
        # dbg(visited)

        dbg_fields =
          grid.fields
          |> Enum.map(fn {k, v} ->
            if k in hits, do: {k, 0}, else: {k, v}
          end)

        Grid2D.debug_print(%{grid | fields: dbg_fields})

        cost = hits |> Enum.map(fn p -> Grid2D.get(grid, p) end) |> Enum.sum()
        dbg(cost - Grid2D.get(grid, {0, 0}))

        raise "done"
      end

      # Get all possible neighbours for the node
      possible_neighbours =
        possible_neighbours(grid, current_pos, current_dir, current_n)
        # |> IO.inspect()
        |> Enum.map(fn {p, cc} ->
          new_dir = dir_for(current_pos, p)
          new_n = if current_dir == new_dir, do: current_n + 1, else: 4
          heur = Grid2D.mh_distance(p, goal)
          {{p, new_dir, new_n}, {current_cost + cc, current_key, heur}}
        end)
        |> Enum.filter(fn {k, _} -> !Map.has_key?(closed_set, k) end)

      open_set =
        Enum.reduce(possible_neighbours, open_set, fn {k, v}, acc ->
          Map.update(acc, k, v, fn old_v ->
            {old_cost, _, _} = old_v
            {cost, _, _} = v
            if cost < old_cost, do: v, else: old_v
          end)
        end)

      dijkstra(grid, open_set, closed_set, goal)
    end

    defp possible_neighbours(grid, {r, c}, current_dir, n) do
      possible_neighbours_(grid, {r, c}, current_dir, n)
      |> Enum.filter(fn {{r, c}, _} ->
        r >= 0 and c >= 0 and r < grid.height and c < grid.width
      end)
    end

    defp possible_neighbours_(grid, {r, c}, current_dir, n) do
      cond do
        current_dir == :still ->
          [
            {{r - 4, c},
             Grid2D.get(grid, {r - 1, c}, 0) + Grid2D.get(grid, {r - 2, c}, 0) +
               Grid2D.get(grid, {r - 3, c}, 0) + Grid2D.get(grid, {r - 4, c}, 0)},
            {{r + 4, c},
             Grid2D.get(grid, {r + 1, c}, 0) + Grid2D.get(grid, {r + 2, c}, 0) +
               Grid2D.get(grid, {r + 3, c}, 0) + Grid2D.get(grid, {r + 4, c}, 0)},
            {{r, c - 4},
             Grid2D.get(grid, {r, c - 1}, 0) + Grid2D.get(grid, {r, c - 2}, 0) +
               Grid2D.get(grid, {r, c - 3}, 0) + Grid2D.get(grid, {r, c - 4}, 0)},
            {{r, c + 4},
             Grid2D.get(grid, {r, c + 1}, 0) + Grid2D.get(grid, {r, c + 2}, 0) +
               Grid2D.get(grid, {r, c + 3}, 0) + Grid2D.get(grid, {r, c + 4}, 0)}
          ]

        # We can move one forward and 4 in every other direction except backward
        current_dir == :right and n >= 4 and n < 10 ->
          [
            {{r - 4, c},
             Grid2D.get(grid, {r - 1, c}, 0) + Grid2D.get(grid, {r - 2, c}, 0) +
               Grid2D.get(grid, {r - 3, c}, 0) + Grid2D.get(grid, {r - 4, c}, 0)},
            {{r + 4, c},
             Grid2D.get(grid, {r + 1, c}, 0) + Grid2D.get(grid, {r + 2, c}, 0) +
               Grid2D.get(grid, {r + 3, c}, 0) + Grid2D.get(grid, {r + 4, c}, 0)},
            {{r, c + 1}, Grid2D.get(grid, {r, c + 1}, 0)}
          ]

        current_dir == :right and n == 10 ->
          [
            {{r - 4, c},
             Grid2D.get(grid, {r - 1, c}, 0) + Grid2D.get(grid, {r - 2, c}, 0) +
               Grid2D.get(grid, {r - 3, c}, 0) + Grid2D.get(grid, {r - 4, c}, 0)},
            {{r + 4, c},
             Grid2D.get(grid, {r + 1, c}, 0) + Grid2D.get(grid, {r + 2, c}, 0) +
               Grid2D.get(grid, {r + 3, c}, 0) + Grid2D.get(grid, {r + 4, c}, 0)}
          ]

        current_dir == :left and n >= 4 and n < 10 ->
          [
            {{r - 4, c},
             Grid2D.get(grid, {r - 1, c}, 0) + Grid2D.get(grid, {r - 2, c}, 0) +
               Grid2D.get(grid, {r - 3, c}, 0) + Grid2D.get(grid, {r - 4, c}, 0)},
            {{r + 4, c},
             Grid2D.get(grid, {r + 1, c}, 0) + Grid2D.get(grid, {r + 2, c}, 0) +
               Grid2D.get(grid, {r + 3, c}, 0) + Grid2D.get(grid, {r + 4, c}, 0)},
            {{r, c - 1}, Grid2D.get(grid, {r, c - 1}, 0)}
          ]

        current_dir == :left and n == 10 ->
          [
            {{r - 4, c},
             Grid2D.get(grid, {r - 1, c}, 0) + Grid2D.get(grid, {r - 2, c}, 0) +
               Grid2D.get(grid, {r - 3, c}, 0) + Grid2D.get(grid, {r - 4, c}, 0)},
            {{r + 4, c},
             Grid2D.get(grid, {r + 1, c}, 0) + Grid2D.get(grid, {r + 2, c}, 0) +
               Grid2D.get(grid, {r + 3, c}, 0) + Grid2D.get(grid, {r + 4, c}, 0)}
          ]

        current_dir == :down and n >= 4 and n < 10 ->
          [
            {{r + 1, c}, Grid2D.get(grid, {r + 1, c}, 0)},
            {{r, c + 4},
             Grid2D.get(grid, {r, c + 1}, 0) + Grid2D.get(grid, {r, c + 2}, 0) +
               Grid2D.get(grid, {r, c + 3}, 0) + Grid2D.get(grid, {r, c + 4}, 0)},
            {{r, c - 4},
             Grid2D.get(grid, {r, c - 1}, 0) + Grid2D.get(grid, {r, c - 2}, 0) +
               Grid2D.get(grid, {r, c - 3}, 0) + Grid2D.get(grid, {r, c - 4}, 0)}
          ]

        current_dir == :down and n == 10 ->
          [
            {{r, c + 4},
             Grid2D.get(grid, {r, c + 1}, 0) + Grid2D.get(grid, {r, c + 2}, 0) +
               Grid2D.get(grid, {r, c + 3}, 0) + Grid2D.get(grid, {r, c + 4}, 0)},
            {{r, c - 4},
             Grid2D.get(grid, {r, c - 1}, 0) + Grid2D.get(grid, {r, c - 2}, 0) +
               Grid2D.get(grid, {r, c - 3}, 0) + Grid2D.get(grid, {r, c - 4}, 0)}
          ]

        current_dir == :up and n >= 4 and n < 10 ->
          [
            {{r - 1, c}, Grid2D.get(grid, {r - 1, c}, 0)},
            {{r, c + 4},
             Grid2D.get(grid, {r, c + 1}, 0) + Grid2D.get(grid, {r, c + 2}, 0) +
               Grid2D.get(grid, {r, c + 3}, 0) + Grid2D.get(grid, {r, c + 4}, 0)},
            {{r, c - 4},
             Grid2D.get(grid, {r, c - 1}, 0) + Grid2D.get(grid, {r, c - 2}, 0) +
               Grid2D.get(grid, {r, c - 3}, 0) + Grid2D.get(grid, {r, c - 4}, 0)}
          ]

        current_dir == :up and n == 10 ->
          [
            {{r, c + 4},
             Grid2D.get(grid, {r, c + 1}, 0) + Grid2D.get(grid, {r, c + 2}, 0) +
               Grid2D.get(grid, {r, c + 3}, 0) + Grid2D.get(grid, {r, c + 4}, 0)},
            {{r, c - 4},
             Grid2D.get(grid, {r, c - 1}, 0) + Grid2D.get(grid, {r, c - 2}, 0) +
               Grid2D.get(grid, {r, c - 3}, 0) + Grid2D.get(grid, {r, c - 4}, 0)}
          ]
      end
    end

    defp lowest_cost(set),
      do:
        set
        |> Enum.sort_by(fn {_, {c, _, h}} -> c + h end)
        |> Enum.at(0)

    defp dir_for({ra, ca}, {rb, cb}) do
      cond do
        ra == rb and ca < cb -> :right
        ra == rb and ca > cb -> :left
        ca == cb and ra < rb -> :down
        ca == cb and ra > rb -> :up
      end
    end

    defp dir_go({r, c}, :still, _), do: {r, c}
    defp dir_go({r, c}, :right, n), do: {r, c - n}
    defp dir_go({r, c}, :left, n), do: {r, c + n}
    defp dir_go({r, c}, :up, n), do: {r + n, c}
    defp dir_go({r, c}, :down, n), do: {r - n, c}

    defp backtrack(_set, nil, acc) do
      Enum.map(acc, fn {p, dir, n} ->
        0..n |> Enum.map(fn x -> dir_go(p, dir, x) end)
      end)
      |> List.flatten()
      |> Enum.uniq()
    end

    defp backtrack(set, pos, acc) do
      backtrack(set, Map.get(set, pos) |> elem(1), [pos | acc])
    end
  end
end

# 1316 too high
