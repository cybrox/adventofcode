defmodule Mix.Tasks.Runday do
  use Mix.Task

  require Logger

  @allowed_days Enum.map(1..24, &String.pad_leading("#{&1}", 2, "0"))
  @allowed_parts ["A", "B"]

  @doc """
  Run the AdventOfCode puzzle for a specific year/day/part.

  Usage: `mix runday <year> <month> <part> [input_file]`
  Example: `mix runday 2015 01 a example_01`
  """
  def run(args) do
    # Processing arguments
    target_year = Enum.at(args, 0, "2015")
    target_day = Enum.at(args, 1, "01")
    target_part = Enum.at(args, 2, "a")
    target_input = Enum.at(args, 3, "input.txt")

    target_day = String.pad_leading(target_day, 2, "0")
    target_part = String.upcase(target_part)

    module_prefix = "Elixir.AdventOfCode.Puzzles"
    module_identifier = :"Year#{target_year}.Day#{target_day}.Part#{target_part}"
    target_module = :"#{module_prefix}.#{module_identifier}"

    # Validating data and module
    if target_day not in @allowed_days do
      _ = Logger.error("Target day must be in the range 01..24!")
      exit(1)
    end

    if target_part not in @allowed_parts do
      _ = Logger.error("Target part must be either A or B!")
      exit(1)
    end

    if !match?({:module, _}, Code.ensure_compiled(target_module)) do
      _ = Logger.error("Module #{target_module} does not exist!")
      exit(1)
    end

    if {:solve, 1} not in apply(target_module, :__info__, [:functions]) do
      _ = Logger.error("Module #{target_module} does not export solve/1!")
      exit(1)
    end

    # Validating input
    priv_dir_path = :code.priv_dir(:adventofcode)
    input_path = "inputs/year_#{target_year}/day_#{target_day}/"
    input_file = Path.join([priv_dir_path, input_path, target_input])

    if !File.exists?(input_file) do
      display_path = Path.relative_to(input_file, priv_dir_path)
      _ = Logger.error("Input file does not exist at priv/#{display_path}")
    end

    # Solve the puzzle (...hopefully)
    apply(target_module, :solve, [File.read!(input_file)])
  end
end
