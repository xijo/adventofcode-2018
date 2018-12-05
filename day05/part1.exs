defmodule Polymer do
  def reduce(input) do
    result = remove_opposite_polarity(input)
    if result == input, do: result, else: reduce(result)
  end

  defp remove_opposite_polarity(list, result \\ [])

  defp remove_opposite_polarity([a, b | tail], result) do
    if abs(a - b) == 32 do
      remove_opposite_polarity(tail, result)
    else
      new_result = [a | result]
      remove_opposite_polarity([b | tail], new_result)
    end
  end

  defp remove_opposite_polarity([last], result) do
    Enum.reverse [last | result]
  end

  defp remove_opposite_polarity([], result) do
    Enum.reverse result
  end
end

# input = 'dabAcCaCBAcCcaDA'
input = String.trim(File.read!("input.txt")) |> to_charlist

IO.write "Length after full reaction: "
input
|> Polymer.reduce
|> length
|> IO.puts

IO.write "Length after full reaction with exclusion: "
Enum.zip(?a..?z, ?A..?Z)
|> Enum.map(fn {low, cap} ->
  input
  |> Enum.reject(fn cp -> cp == low || cp == cap end)
  |> Polymer.reduce
  |> length
end)
|> Enum.min
|> IO.puts
