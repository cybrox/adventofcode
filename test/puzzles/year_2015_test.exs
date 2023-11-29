defmodule AdventOfCode.Puzzles.Year2015Test do
  use ExUnit.Case, async: true

  require YearTestGenerator

  @tag :skip
  describe "solutions for year 2015" do
    YearTestGenerator.generate_test_blocks(
      AdventOfCode.Puzzles.Year2015,
      [
        {Day01.PartA, 280},
        {Day01.PartB, 1797},
        {Day02.PartA, 1_586_300},
        {Day02.PartB, 3_737_498}
      ]
    )
  end
end
