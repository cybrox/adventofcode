defmodule AdventOfCode.Common.Shared do
  @moduledoc """
  This module helps facilitate code sharing between two parts of an answer with
  our opinionated way of solving the Advent of Code puzzles.

  For each puzzle, a module `AdventOfCode.Puzzles.YearXXXX.DayXX` is created.
  Within this module, two submodules `PartA` and `PartB` are created. Each of
  these submodules has a `solve/1` function that takes the input and returns the
  answer.

  Often times, the custom input parsing is the same for both parts of the answer.
  This module helps facilitate code sharing between the two parts.

  For this to work, the shared code must be placed in a module named `Shared`
  within the puzzle module and **above** the `PartA` and `PartB` submodules.
  """

  defmacro __using__(opts) do
    caller_module = __CALLER__.module

    parent_module_segments =
      caller_module
      |> Module.split()
      |> Enum.slice(0..-2)

    shared_name = Keyword.get(opts, :module, :Shared)
    shared_module = module_from_segments([:"Elixir"] ++ parent_module_segments ++ [shared_name])

    if !match?({:module, _}, Code.ensure_compiled(shared_module)) do
      error_reason = "#{caller_module} used Shared but #{shared_module} does not exist!"
      error_hint = "Ensure that the Shared module is defined above the PartA and PartB modules."
      raise "#{error_reason}\n#{error_hint}"
    end

    quote do
      import unquote(shared_module)
    end
  end

  defp module_from_segments(segments), do: segments |> Enum.join(".") |> String.to_atom()
end
