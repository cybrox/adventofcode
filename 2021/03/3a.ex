input =
  "./3.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))

defmodule Solution do
  def evaluate(input) do
    gamma = zipmap(input)
    epsilon = invert(gamma)

    list_to_int(gamma) * list_to_int(epsilon)
  end

  defp zipmap(input) do
    input
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(fn bits ->
      total = Enum.count(bits)
      ones = Enum.count(bits, &(&1 == "1"))
      if ones > total / 2, do: "1", else: "0"
    end)
  end

  # We invert the list of bits manually instaed of using Bitwise.~~~, as that
  # does seem to play into signed/unsigned integer evaluation somehow. In its
  # docs it states that ~~~2 = -3. No idea why (0b1) would be evaluated to -3
  defp invert(list), do: invert(list, [])
  defp invert([], acc), do: acc
  defp invert(["1" | t], acc), do: invert(t, acc ++ ["0"])
  defp invert(["0" | t], acc), do: invert(t, acc ++ ["1"])

  defp list_to_int(list),
    do:
      list
      |> Enum.join("")
      |> Integer.parse(2)
      |> elem(0)
end

IO.puts("Diagnostic gamma * epsilon is #{Solution.evaluate(input)}")
