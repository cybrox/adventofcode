defmodule Mix.Tasks.Newday do
  use Mix.Task

  require Logger

  @allowed_days Enum.map(1..24, &String.pad_leading("#{&1}", 2, "0"))
  @source_template """
  defmodule AdventOfCode.Puzzles.Year%YEAR%.Day%DAY% do
    require Logger

    alias AdventOfCode.Common.Input

    defmodule PartA do
      def solve(input) do
        IO.inspect(input)
      end
    end

    defmodule PartB do
      def solve(input) do
        IO.inspect(input)
      end
    end
  end
  """

  @doc """
  Create the AdventOfCode solution files for a specific year/day.

  Usage: `mix newday <year> <month>`
  Example: `mix newday 2015 01`
  """
  def run(args) do
    # Processing arguments
    target_year = Enum.at(args, 0, "2015")
    target_day = Enum.at(args, 1, "01")

    target_day = String.pad_leading(target_day, 2, "0")

    module_prefix = "Elixir.AdventOfCode.Puzzles"
    module_identifier = :"Year#{target_year}.Day#{target_day}"
    target_module = :"#{module_prefix}.#{module_identifier}"

    # Validating data and module
    if target_day not in @allowed_days do
      _ = Logger.error("Target day must be in the range 01..24!")
      exit(1)
    end

    if match?({:module, _}, Code.ensure_compiled(target_module)) do
      _ = Logger.error("Module #{target_module} already exists!")
      exit(1)
    end

    # Generate the source and input files
    built_app_dir = Application.app_dir(:adventofcode)
    source_app_dir = String.replace_suffix(built_app_dir, "_build/dev/lib/adventofcode", "")

    lib_directory = Path.join(source_app_dir, "lib/adventofcode/puzzles")
    priv_directory = Path.join(source_app_dir, "priv/inputs")

    File.mkdir_p(Path.join(lib_directory, "year_#{target_year}"))
    File.mkdir_p(Path.join(priv_directory, "year_#{target_year}"))
    File.mkdir_p(Path.join(priv_directory, "year_#{target_year}/day_#{target_day}"))

    File.touch(Path.join(priv_directory, "year_#{target_year}/day_#{target_day}/input.txt"))

    source_file = Path.join(lib_directory, "year_#{target_year}/day_#{target_day}.ex")

    source_template =
      @source_template
      |> String.replace("%YEAR%", target_year)
      |> String.replace("%DAY%", target_day)

    File.write(source_file, source_template)

    _ = Logger.info("Successfully created puzzle scaffold for #{target_year}/#{target_day}")
  end
end
