# AdventOfCode in Elixir
Solving [AdventOfCode](https://adventofcode.com) puzzles in [Elixir](https://elixir-lang.org/).

## Mix tasks
### `$ mix newday <year> <day>`
Creates the solution template for a specific day. This will create:
* `lib/adventofcode/puzzles/year_<year>/day_<day>.ex`
* `priv/inputs/year_<year>/day_<day>/input.txt`

It will fill the solution (`.ex`) file with a simple template.

### `$ mix runday <year> <day> <part> [input]`
Run the solution for a specific year, day and part (A or B) and a specific input file.    
If nothing is specified, `input.txt` will be used but for testing with a subset or example, it can be useful to use a different file instead. E.g. `mix runday 2015 01 example_01.txt`

## Workflow
* Run `mix newday 2015 01`
* Copy the puzzle input to `input.txt`
* Solve the puzzle and run it with `mix runday 2015 01`

## Directory structure
This repository uses a standardized directory structure for all puzzles, so solutions are easy to create and easy to understand. The following tree shows the most important directories:
```
/
├─ lib/
│  ├─ adventofcode
│  │  ├─ common         <- Common helper modules
│  │  ├─ puzzles
│  │     ├─ year_xxxx   <- Puzzle files for a specific year
│  ├─ mix
│     ├─ tasks
├─ priv/
   ├─ inputs
      ├─ year_xxxx      <- Puzzle inputs for a specific year
         ├─ day_xx      <- Puzzle inputs for a specific day
```

For example the puzzle for the 1. December 2015 is solved in:
* Solution: `lib/adventofcode/puzzles/year_2015/day_01.ex`
* Inputs:  `priv/inputs/year_2015/day_01/*.txt`

## Solution structure
Each puzzles is solved using a solution structure that is generated as a template by `mix newday`.

For easy input parsing, `AdvenOfCode.Common.Input` is always aliased. Additional common modules can be aliased as required by the puzzle.
```elixir
defmodule AdventOfCode.Puzzles.Year2015.Day01 do
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
```

## Testing
By default, when running `mix test` only unit tests for common modules such as `AdventOfCode.Common.Input` will be run. However, since all inputs and solutions are stored in the repository, tests for the individual puzzles are also created.

The `test/puzzles/year_xxxx_test.exs` files will provide tests for a specific year's puzzles. They utilize a macro defined in the test helper to generate one test case per day and part from a list of day/part and solution pairs.

To run all puzzles and test their output, run `RUN_PUZZLE_TESTS=true mix test`.

## Additional tidbits
### Sharing code between parts
It is often required to share input parsing or some processing between part A and part B of a day's puzzle. To facilitate this, `AdventOfCode.Common.Shared` can be used, which contains a macro that will import all functions from the shared module in the same day. 

Please note that the `.Shared` module **must** be defined above the `PartA` and `PartB` modules.
```elixir
defmodule AdventOfCode.Puzzles.Year2015.Day01 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule Shared do
    def ident(x), do: x
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # ident/1 can now be used here
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # ident/1 can now be used here
  end
end
```
