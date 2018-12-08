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

grid = Grid.points(grid)
       |> Enum.reduce(grid, fn a, acc ->
         distances = Enum.group_by(coords, fn b -> Manhattan.distance(a, b) end)
         min = distances |> Map.keys |> Enum.min
         value = if length(distances[min]) == 1, do: List.first(distances[min]), else: nil
         Grid.update acc, a, value
       end)

# Remove outer points
inner_points = coords
               |> Enum.reject(fn c ->
                 top = Map.values(grid[0])
                 bottom = Map.values(grid[length(Map.keys(grid))-1])
                 left = Enum.map(grid, fn {_, row} -> row[0] end)
                 right = Enum.map(grid, fn {_, row} -> row[length(Map.keys(row))-1] end)
                 Enum.member?(top ++ bottom ++ left ++ right, c)
               end)

inner_points
|> Enum.map(fn ip ->
  Grid.count_if(grid, fn v -> v == ip end)
end)
|> Enum.max
|> IO.inspect
