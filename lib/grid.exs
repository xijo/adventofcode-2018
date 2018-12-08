defmodule Grid do
  def build(size) when is_integer(size) do
    build({size, size})
  end

  def build({x, y}) do
    Enum.reduce(0..(y-1), %{}, fn i, cols ->
      row = Enum.reduce(0..(x-1), %{}, fn j, rows -> put_in rows[j], nil end)
      put_in cols[i], row
    end)
  end

  def update(grid, {x, y}, mutator) when is_function(mutator) do
    new_value = mutator.(grid[x][y])
    update(grid, {x, y}, new_value)
  end

  def update(grid, {x, y}, new_value) do
    put_in grid[x][y], new_value
  end

  # Notice the flat_map which makes up for the sloppy Map.values
  def all?(grid, filter) do
    Enum.flat_map(grid, fn {_, row} -> Map.values(row) end)
    |> Enum.all?(filter)
  end

  def points(grid) do
    Enum.reduce(grid, [], fn {x, row}, result ->
      Enum.reduce(row, result, fn {y, values}, inner_result ->
        [{x,y} | inner_result]
      end)
    end)
  end

  # Convert start position and size into a x range and a y range
  def span({x, y}, {w, h}) do
    [x..(x+w-1), y..(y+h-1)]
  end

  # Slice a subgrid from an existing one
  def slice(grid, {x, y}, size) do
    [rangex, rangey] = span({x, y}, size)
    Map.take(grid, rangex)
    |> Enum.reduce(%{}, fn {key_x, value_x}, acc ->
      cols = Map.take(value_x, rangey)
             |> Enum.reduce(%{}, fn {key_y, value_y}, acc ->
               put_in acc[key_y - y], value_y # Remove initial offset
             end)
      put_in acc[key_x - x], cols # Remove initial offset
    end)
  end

  def count_if(grid, function) do
    Enum.reduce(grid, 0, fn {_, row}, result ->
      Enum.reduce(row, result, fn {_, value}, inner_result ->
        if function.(value), do: inner_result + 1, else: inner_result
      end)
    end)
  end

  def inspect(grid) do
    IO.write "   _"
    Enum.each(1..length(Map.values(grid[0])), fn _ -> IO.write("_") end)
    IO.write "\n"
    Enum.each(grid, fn {row_no, row} ->
      IO.write "#{row_no} |"
      Enum.each(row, fn {_, col} ->
        IO.write col
      end)
      IO.write "\n"
    end)
  end
end

ExUnit.start
ExUnit.configure trace: true

defmodule GridTest do
  use ExUnit.Case

  test "build square" do
    assert Grid.build(2) == %{0 => %{0 => nil, 1 => nil}, 1 => %{0 => nil, 1 => nil}}
  end

  test "build rectangular" do
    assert Grid.build({1,2}) == %{0 => %{0 => nil}, 1 => %{0 => nil}}
    assert Grid.build({2,1}) == %{0 => %{0 => nil, 1 => nil}}
  end

  test "update" do
    grid = Grid.build(2)
    assert Grid.update(grid, {0,0}, 42) == %{0 => %{0 => 42, 1 => nil}, 1 => %{0 => nil, 1 => nil}}
  end

  test "update with mutator" do
    grid = Grid.build(2)
           |> Grid.update({0,0}, 23)
    assert Grid.update(grid, {0,0}, &(&1 + 19)) == %{0 => %{0 => 42, 1 => nil}, 1 => %{0 => nil, 1 => nil}}
  end

  test "count_if" do
    grid = %{
      0 => %{ 0 => 5, 1 => 1 },
      1 => %{ 0 => 8, 0 => nil }
    }
    assert Grid.count_if(grid, &(&1 > 1)) == 2
  end

  test "span" do
    assert Grid.span({2, 3}, {4, 4}) == [2..5, 3..6]
  end

  test "all? returns true" do
    grid = %{0 => %{0 => "a"}, 1 => %{1 => "a"}}
    assert Grid.all?(grid, fn x -> x == "a" end) == true
  end

  test "slice" do
    grid = Grid.build(4) |> Grid.update({1,1}, "a")
    slice = Grid.slice(grid, {1,1}, {2,2})
    assert slice[0][0] == "a"
    assert slice[0][1] == nil
    assert slice[1][0] == nil
    assert slice[1][1] == nil
  end
end
