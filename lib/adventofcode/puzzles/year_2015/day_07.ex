defmodule AdventOfCode.Puzzles.Year2015.Day07 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule Shared do
    import Bitwise

    # The max number size is 2^16
    @number_size 65536

    # Parse the parts of a single instruction line into a tuple of the form:
    # `{instruction, operands, target, mapper}` where iunstruction is one of
    # `:move`, `:not`, `:and`, `:or`, `:lshift`, `:rshift`, operands is a tuple
    # of the form `{a, b}` or a single value `a`, target is the register to
    # store the result in, and mapper is a function that takes one or two
    # arguments and returns the result of the operation.
    def parse_instruction(parts) do
      case parts do
        [a, "->", target] -> {:move, a, target, & &1}
        ["NOT", a, "->", target] -> {:not, a, target, &bnot/1}
        [a, "AND", b, "->", target] -> {:and, {a, b}, target, &band/2}
        [a, "OR", b, "->", target] -> {:or, {a, b}, target, &bor/2}
        [a, "LSHIFT", n, "->", target] -> {:lshift, {a, n}, target, &bsl/2}
        [a, "RSHIFT", n, "->", target] -> {:rshift, {a, n}, target, &bsr/2}
      end
    end

    # Emulate a circuit by running each instruction in order, skipping any that
    # have already been run. Returns the final state of the registers.
    def emulate_circuit([], registers), do: registers

    def emulate_circuit([h | t], registers) do
      {skipped, registers} = run_instruction(h, registers)
      emulate_circuit(t ++ skipped, registers)
    end

    # Runs a single instruction, returning a tuple of the form `{skipped, registers}`
    # where `skipped` is a list of instructions that were skipped because they did not
    # have all their operands available, and `registers` is the updated register state.
    defp run_instruction({_, {from_a, from_b}, to, mapper} = inst, registers) do
      with {:ok, a} <- load(registers, from_a),
           {:ok, b} <- load(registers, from_b) do
        {[], Map.put(registers, to, max16bit(mapper.(a, b)))}
      else
        :error -> {[inst], registers}
      end
    end

    defp run_instruction({_, from_a, to, mapper} = inst, registers) do
      with {:ok, a} <- load(registers, from_a) do
        {[], Map.put(registers, to, max16bit(mapper.(a)))}
      else
        :error -> {[inst], registers}
      end
    end

    # Load a value from a register or a number. Returns a tuple of the form
    # `{ok, value}` or `:error` if the value could not be loaded (e.g the
    # register does not yet exist and the address is not numerical).
    defp load(_registers, addr) when is_number(addr), do: {:ok, addr}

    defp load(registers, addr) when is_binary(addr) do
      case Integer.parse(addr) do
        {number, _} -> {:ok, number}
        :error -> Map.fetch(registers, addr)
      end
    end

    # Clamp a value to 16 bits by simulating overflow.
    defp max16bit(v) when v >= 0, do: v
    defp max16bit(v), do: @number_size + v
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    def solve(input) do
      # We want to emulate the circuit by running each instruction in order, but
      # only if all its operands are available. If they are not, we add the instruction
      # back to the end of the list and try again later until all instructions have
      # been run. In the end, we want to know the value of register `a`.
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Input.split_by_char(" ", trim: true)
        |> Enum.map(&Shared.parse_instruction/1)

      data
      |> emulate_circuit(%{})
      |> Map.get("a")
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to emulate the circuit by running each instruction in order, but
    # only if all its operands are available. If they are not, we add the instruction
    # back to the end of the list and try again later until all instructions have
    # been run. We want to then write the value of register `a` to register `b`,
    # clear all other registers, and run the circuit again and see what the value
    # of register `a` is after that.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Input.split_by_char(" ", trim: true)
        |> Enum.map(&Shared.parse_instruction/1)

      # Get the value of register `a` from part A
      result_a = data |> emulate_circuit(%{}) |> Map.get("a")

      # [!] When simply running the circuit again with the value of `a` from part A,
      # in register `b`, we get the same result as in part A. This is because one of
      # the first instructions is `44430 -> b`, which overwrites the value of `b`.
      # I am not sure if this is intentional or not, but we get the correct result
      # by simply removing this instruction from the list. We could have also just run
      # the instructions in reverse order, but the puzzle hints at neither of these
      # being intended. I assume the author anticipated that the instructions are not
      # simply run in order but instead depending on what output is written on each
      # instruction, which would be more efficient and would prevent this issue.
      sanitized_data =
        data
        |> Enum.filter(fn
          {:move, _, "b", _} -> false
          _ -> true
        end)

      sanitized_data |> emulate_circuit(%{"b" => result_a}) |> Map.get("a")
    end
  end
end
