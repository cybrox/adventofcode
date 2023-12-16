ExUnit.start()

defmodule YearTestGenerator do
  defmacro generate_test_blocks(parent_module, solutions) do
    solutions
    |> Enum.filter(fn {_, expected} -> expected != :_ end)
    |> Enum.map(&generate_test_block(parent_module, &1))
  end

  defp generate_test_block(parent_module, solution) do
    {{:__aliases__, _, [day, part]}, expected_result} = solution
    {:__aliases__, _, parent_segments} = parent_module

    target_module =
      [:"Elixir", parent_segments, day, part]
      |> List.flatten()
      |> Enum.map(&"#{&1}")
      |> Enum.join(".")

    target_year = parent_segments |> List.last() |> to_string() |> String.slice(4..-1)
    target_day = day |> to_string() |> String.slice(3..-1)
    target_part = part |> to_string() |> String.slice(-1..-1)

    priv_dir_path = :code.priv_dir(:adventofcode)
    input_path = "inputs/year_#{target_year}/day_#{target_day}/"
    input_file = Path.join([priv_dir_path, input_path, "input.txt"])
    load_path = Path.relative_to(input_file, priv_dir_path)

    skip_tag = if System.get_env("RUN_PUZZLE_TESTS"), do: "puzzle", else: "skip"
    day_tag = "#{target_year}-#{target_day}"
    part_tag = "#{day_tag}-#{target_part}"
    part_tag_lc = String.downcase(part_tag)

    quote do
      @tag [
        {unquote(:"#{skip_tag}"), true},
        {unquote(:"#{day_tag}"), true},
        {unquote(:"#{part_tag}"), true},
        {unquote(:"#{part_tag_lc}"), true},
        {:timeout, :infinity}
      ]
      test unquote("result for #{day} #{part} is correct") do
        input_file = unquote("priv/#{load_path}")
        assert File.exists?(input_file)

        input_data = File.read!(input_file)

        assert apply(unquote(:"#{target_module}"), :solve, [input_data]) ==
                 unquote(expected_result)
      end
    end
  end
end
