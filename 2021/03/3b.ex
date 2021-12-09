input =
  "./3.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))

defmodule Solution do
  def evaluate(list, filter), do: evaluate(list, filter, 0)
  def evaluate([last], _, _), do: list_to_int(last)

  def evaluate(list, filter, bid) do
    col = list |> Enum.map(&Enum.at(&1, bid))

    {ones, zeroes} = Enum.reduce(col, {0, 0}, fn n, {o, z} -> {if1(o, n), if0(z, n)} end)
    cb = filter.(ones, zeroes)

    evaluate(Enum.filter(list, &(Enum.at(&1, bid) == cb)), filter, bid + 1)
  end

  defp if0(acc, "0"), do: acc + 1
  defp if0(acc, "1"), do: acc
  defp if1(acc, "1"), do: acc + 1
  defp if1(acc, "0"), do: acc

  defp list_to_int(list),
    do:
      list
      |> Enum.join("")
      |> Integer.parse(2)
      |> elem(0)
end

oxygen = Solution.evaluate(input, fn o, z -> if o < z, do: "1", else: "0" end)
co2scrub = Solution.evaluate(input, fn o, z -> if o >= z, do: "1", else: "0" end)

IO.puts("Diagnostic oxygen * co2scrub is #{oxygen * co2scrub}")
