defmodule AdventOfCode.Puzzles.Year2015Test do
  use ExUnit.Case, async: true

  require YearTestGenerator

  @tag :skip
  describe "solutions for year 2015" do
    YearTestGenerator.generate_test_blocks(
      AdventOfCode.Puzzles.Year2015,
      [
        {Testee.Day01.PartA, 280},
        {Testee.Day01.PartB, 1797},
        {Testee.Day02.PartA, 1_586_300},
        {Testee.Day02.PartB, 3_737_498}
      ]
    )
  end
end
