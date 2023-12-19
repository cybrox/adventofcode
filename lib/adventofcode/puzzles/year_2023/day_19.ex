defmodule AdventOfCode.Puzzles.Year2023.Day19 do
  require Logger

  alias AdventOfCode.Common.Input
  alias AdventOfCode.Common.Util

  defmodule Shared do
    # Parse the puzzle input by splitting at the empty line to obtain the workflow data
    # and the input data and then parse these separately.
    def parse_input(input, matcher_type) do
      [workflow_data, input_data] = input |> Input.split_by_char("\n\n", trim: true)
      {parse_workflow_data(workflow_data, matcher_type), parse_input_data(input_data)}
    end

    # Parse the workflow data block into a map of `name -> rules`
    defp parse_workflow_data(workflow_data, matcher_type) do
      workflow_data
      |> Input.split_by_line(trim: true)
      |> Enum.map(&parse_workflow_line(&1, matcher_type))
      |> Enum.into(%{})
    end

    # Parse a single line of the workflow instructions.
    # This separates the line of format `name {rules}` into a tuple of `{name, rules}`
    # where rules is further parsed by `parse_workflow_rule/1`
    defp parse_workflow_line(line, matcher_type) do
      [name, data] = line |> String.replace("}", "") |> String.split("{", trim: true)
      {name, data |> String.split(",") |> Enum.map(&parse_workflow_rule(&1, matcher_type))}
    end

    # Parse a single workflow rule into a tuple of a function to evaluate the rule and a target.
    # For the last rule in the set, we simply use `&(true)` to always match. For part B, we cannot
    # use a function to evaluate `4000^4` rules one-by-one, so we instead return a tuple with a
    # matching range and the target.
    defp parse_workflow_rule(rule, :function) do
      case String.split(rule, ":") do
        [target] -> {fn _ -> true end, target}
        [condition, target] -> parse_workflow_function(condition, target)
      end
    end

    defp parse_workflow_rule(rule, :range) do
      case String.split(rule, ":") do
        [target] -> {true, target}
        [condition, target] -> parse_workflow_range(condition, target)
      end
    end

    # Parse a workflow function string into an actual anonymous function.
    # The puzzle input only uses `key<val` and `key>val` as rule functions.
    defp parse_workflow_function(condition, target) do
      [key, limit] = String.split(condition, ~r/[\<\>]/, parts: 2)
      limit_num = String.to_integer(limit)

      if String.contains?(condition, "<") do
        {fn data -> Map.get(data, key) < limit_num end, target}
      else
        {fn data -> Map.get(data, key) > limit_num end, target}
      end
    end

    # Parse a workflow function string into a range that can be used to get the
    # intersection or the complement of a given range to filter inputs.
    defp parse_workflow_range(condition, target) do
      [key, limit] = String.split(condition, ~r/[\<\>]/, parts: 2)
      limit_num = String.to_integer(limit)

      if String.contains?(condition, "<") do
        {key, 0..(limit_num - 1), target}
      else
        {key, (limit_num + 1)..4000, target}
      end
    end

    # Parse the input data block line by line
    defp parse_input_data(input_data) do
      input_data
      |> Input.split_by_line(trim: true)
      |> Enum.map(&parse_input_line/1)
      |> Enum.map(&Enum.into(&1, %{}))
    end

    # Parse a single line of the given input.
    # This maps the written map of `{k:v,k:v}` to an elixir map
    defp parse_input_line(line) do
      line
      |> String.replace(["{", "}"], "")
      |> String.split(",", trim: true)
      |> Enum.map(fn option ->
        [k, v] = String.split(option, "=", parts: 2)
        {k, String.to_integer(v)}
      end)
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to apply the given rules to all of our inputs and see where they end up in.
    # After processing all inputs, we only take the ones that landed in `A` and sum up all
    # the numbers of their parameters to get the final result.
    def solve(input) do
      {workflows, inputs} = parse_input(input, :function)

      inputs
      |> Enum.map(fn input -> {input, apply_workflow(input, "in", workflows)} end)
      |> Enum.filter(fn {_, target} -> target == "A" end)
      |> Enum.map(fn {input, _} -> input |> Enum.map(fn {_k, v} -> v end) |> Enum.sum() end)
      |> Enum.sum()
    end

    # Apply the workflow `current` to the given input if it is not alredy `A` or `R`.
    # This uses the matcher functions generated in the parsing to get the first rule
    # that matches for any given input and send it to the new target.
    defp apply_workflow(_input, "A", _workflows), do: "A"
    defp apply_workflow(_input, "R", _workflows), do: "R"

    defp apply_workflow(input, current, workflows) do
      target = workflows |> Map.get(current) |> Enum.find(fn {f, _} -> f.(input) end) |> elem(1)
      apply_workflow(input, target, workflows)
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We still want to find the sum of all the inputs that end up in `A`, however instead of a
    # fixed input list we now need to try every possible input for parameter values `1..4000`.
    # Since this is 4000^4 inputs in total, we cannot simply brute force this and instead work
    # with a list of ranges that we pass around.
    def solve(input) do
      {workflows, _inputs} = parse_input(input, :range)

      inputs = [{"in", %{"x" => 1..4000, "m" => 1..4000, "a" => 1..4000, "s" => 1..4000}}]

      apply_workflow(inputs, workflows)
      |> Enum.filter(fn {k, _} -> k == "A" end)
      |> Enum.map(fn {_, v} -> Enum.map(v, fn {_, v} -> Range.size(v) end) end)
      |> Enum.map(&Enum.product/1)
      |> Enum.sum()
    end

    # Check if all inputs have ended up in either `A` or `R` (we assume this will happen and the
    # puzzle input is actually possible to solve). If they did, return them. Otherwise, apply the
    # next workflow to every input in the list.
    defp apply_workflow(inputs, workflows) do
      if Enum.all?(inputs, fn {current, _} -> current in ["A", "R"] end) do
        inputs
      else
        apply_workflow_for(inputs, workflows)
      end
    end

    defp apply_workflow_for(inputs, workflows) do
      inputs =
        inputs
        |> Enum.map(fn {current, input} ->
          apply_workflow_for_input({current, input}, Map.get(workflows, current))
        end)
        |> List.flatten()

      apply_workflow(inputs, workflows)
    end

    # Apply the current workflow to a specific input, ignoring the ones in `A` and `R`
    # For the others, process a single input by moving the parts of it that intersect
    # with the rule range to the target and keeping the rest intact until the last
    # rule, which will move the rest the default target of the workflow.
    defp apply_workflow_for_input({"A", input}, _), do: {"A", input}
    defp apply_workflow_for_input({"R", input}, _), do: {"R", input}

    defp apply_workflow_for_input({_, input}, rules) do
      Enum.reduce(rules, {[], input}, fn
        {key, range, target}, {ns, rest} ->
          in_r = rest |> Map.update(key, nil, fn r -> Util.intersect_onto(r, range) end)
          out_r = rest |> Map.update(key, nil, fn r -> Util.complement_onto(r, range) end)

          {ns ++ [{target, in_r}], out_r}

        {true, target}, {ns, rest} ->
          {ns ++ [{target, rest}], %{}}
      end)
      |> elem(0)
    end
  end
end
