Code.require_file("../lib/grid.exs")

defmodule Manhattan do
  def distance({a1, a2}, {b1, b2}) do
    abs(a1 - b1) + abs(a2 - b2)
  end
end

coords = File.read!("input.txt")
# coords = File.read!("example.txt")
         |> String.trim
         |> String.split("\n")
         |> Enum.map(fn line ->
           [x, y] = line |> String.split(", ") |> Enum.map(&String.to_integer/1)
           {x, y}
         end)

grid = Grid.build(400)
# grid = Grid.build(10)

Grid.points(grid)
|> Enum.filter(fn point ->
  Enum.reduce(coords, 0, fn coord, distance ->
    distance + Manhattan.distance(point, coord)
  end) < 10000
  # end) < 32
end)
|> length
|> IO.inspect
