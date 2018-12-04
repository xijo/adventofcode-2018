defmodule Schedule do
  def observe({schedule, guard, asleep_since}, line) do
    gid = Regex.run(~r/Guard #(\d+)/, line, capture: :all_but_first)
    time = Regex.run(~r/\d{2}:(\d{2})\]/, line) |> List.last |> String.to_integer

    cond do
      # If guard changes, just go on with a new guard and reset asleep_since
      gid ->
        new_guard = gid |> List.first |> String.to_integer
        {schedule, new_guard, nil}

      # If guard falls asleep take current time as asleep_time
      String.contains?(line, "falls asleep") ->
        {schedule, guard, time}

      # If guard wakes up calculate the time slept and store it in the schedule
      String.contains?(line, "wakes up") ->
        guard_schedule = schedule[guard] || %{}
        asleep_sum     = guard_schedule[:asleep_sum] || 0
        guard_schedule = put_in guard_schedule[:asleep_sum], asleep_sum + (time - asleep_since)

        guard_schedule = asleep_since..(time - 1)
        |> Enum.reduce(guard_schedule, fn min, acc -> put_in acc[min], ((acc[min] || 0) + 1) end)

        new_schedule = put_in schedule[guard], guard_schedule
        {new_schedule, guard, nil}
    end
  end

  def strategy1({schedule, _, _}) do
    schedule
    |> Enum.max_by(fn {_, %{:asleep_sum => sum}} -> sum end)
    |> calc_result
  end

  def strategy2({schedule, _, _}) do
    schedule
    |> Enum.max_by(fn {_, guard_schedule} ->
      {_, count} = max_by_except_asleep(guard_schedule)
      count
    end)
    |> calc_result
  end

  defp max_by_except_asleep(schedule) do
    Enum.max_by(schedule, fn
      {:asleep_sum, _} -> 0
      {_, value}     -> value
    end)
  end

  defp calc_result({guard, guard_schedule}) do
    {min, _} = max_by_except_asleep(guard_schedule)
    guard * min
  end
end

schedule = File.read!("input.txt")
           |> String.trim
           |> String.split("\n")
           |> Enum.sort
           |> Enum.reduce({%{}, nil, nil}, fn line, acc -> Schedule.observe(acc, line) end)

IO.write "Strategy 1: "
schedule |> Schedule.strategy1 |> IO.puts

IO.write "Strategy 2: "
schedule |> Schedule.strategy2 |> IO.puts
