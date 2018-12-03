defmodule Box do
  def id_difference(a, b, diff \\ 0)

  def id_difference([a | atail], [b | btail], diff) do
    new_diff = diff + if a != b, do: 1, else: 0
    id_difference atail, btail, new_diff
  end

  def id_difference([], [], diff) do
    diff
  end
end

ids = File.read!("input.txt")
|> String.trim
|> String.split("\n")

Enum.each(ids, fn v1 ->
  v1c = String.graphemes(v1)
  Enum.each(ids, fn v2 ->
    v2c = String.graphemes(v2)
    if Box.id_difference(v1c, v2c) == 1 do
      v1c
      |> Enum.filter(fn x -> Enum.member?(v2c, x) end)
      # MapSet.intersection(MapSet.new(v1c), MapSet.new(v2c))
      |> Enum.join
      |> IO.inspect
    end
  end)
end)
