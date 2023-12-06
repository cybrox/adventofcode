defmodule AdventOfCode.Puzzles.Year2020Test do
  use ExUnit.Case, async: true

  require YearTestGenerator

  describe "solutions for year 2020" do
    YearTestGenerator.generate_test_blocks(
      AdventOfCode.Puzzles.Year2020,
      [
        {Day15.PartA, 475},
        {Day15.PartB, 11261}
      ]
    )
  end
end
