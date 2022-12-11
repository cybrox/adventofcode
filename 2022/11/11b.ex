lines =
  "./11.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n\n", trim: true)
  |> Enum.map(&String.split(&1, "\n", trim: true))

defmodule Solution do
  @rounds 10000

  def juggle(lines) do
    monkeys = lines |> Enum.map(&parse_monkey/1)

    mod_clamp =
      lines
      |> Enum.reduce(1, fn m, acc ->
        divisor = m |> Enum.at(3) |> String.split() |> Enum.at(-1) |> String.to_integer()
        acc * divisor
      end)

    [a, b] =
      0..(@rounds - 1)
      |> Enum.reduce(monkeys, fn _, acc -> proc_round(acc, mod_clamp) end)
      |> Enum.map(fn {_, _, _, _, _, checks} -> checks end)
      |> Enum.sort()
      |> Enum.slice(-2..-1)

    a * b
  end

  defp proc_round(monkeys, mod_clamp) do
    Enum.reduce(0..(Enum.count(monkeys) - 1), monkeys, fn i, acc ->
      throwing =
        acc
        |> Enum.at(i)
        |> proc_monkey(mod_clamp)
        |> Enum.reduce(%{}, fn {val, to}, acc ->
          Map.put(acc, to, Map.get(acc, to, []) ++ [val])
        end)

      Enum.map(acc, fn {name, items, op, test, then, checks} ->
        new_items = if name == i, do: [], else: items ++ Map.get(throwing, name, [])
        new_chekcs = if name == i, do: checks + Enum.count(items), else: checks
        {name, new_items, op, test, then, new_chekcs}
      end)
    end)
  end

  defp proc_monkey({_name, items, op, test, then, _checks}, mod_clamp),
    do:
      Enum.map(items, fn item ->
        {rem(item |> op.(), mod_clamp), item |> op.() |> test.() |> then.()}
      end)

  defp parse_monkey([name, items, op, test, if_t, if_f]) do
    {
      parse_monkey_name(name),
      parse_monkey_items(items),
      parse_monkey_op(op),
      parse_monkey_test(test),
      prase_monkey_throws(
        String.split(if_t, " ", trim: true),
        String.split(if_f, " ", trim: true)
      ),
      0
    }
  end

  defp parse_monkey_name(<<"Monkey ", id::binary>>),
    do: id |> String.slice(0..-2) |> String.to_integer()

  defp parse_monkey_items(<<"  Starting items: ", items::binary>>),
    do: String.split(items, ", ") |> Enum.map(&String.to_integer/1)

  defp parse_monkey_op(<<"  Operation: new = old ", op::binary>>), do: monkey_op_to_fn(op)
  defp parse_monkey_test(<<"  Test: divisible by ", num::binary>>), do: monkey_test_to_fn(num)

  defp prase_monkey_throws([_, _, _, _, _, if_t_num], [_, _, _, _, _, if_f_num]) do
    fn x -> if x == true, do: String.to_integer(if_t_num), else: String.to_integer(if_f_num) end
  end

  defp monkey_op_to_fn("* old"), do: fn x -> x * x end

  defp monkey_op_to_fn(<<op::binary-size(1), " ", num::binary>>),
    do: fn x -> apply(Kernel, :"#{op}", [x, String.to_integer(num)]) end

  defp monkey_test_to_fn(num_str), do: fn x -> rem(x, String.to_integer(num_str)) == 0 end
end

IO.puts("The level of monkey business after 10000 rounds is #{Solution.juggle(lines)}")
