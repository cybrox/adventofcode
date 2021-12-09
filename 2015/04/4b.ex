input =
  "./4.input.txt"
  |> File.read!()
  |> String.trim()

defmodule Solution do
  def iter_for(seed), do: iter_for(seed, 0)

  def iter_for(seed, n) do
    <<l::binary-size(6), _::binary>> = :crypto.hash(:md5, seed <> "#{n}") |> Base.encode16()
    if l == "000000", do: n, else: iter_for(seed, n + 1)
  end
end

IO.puts("Found hash with 5 leading zeroes at iteration #{Solution.iter_for(input)}")
