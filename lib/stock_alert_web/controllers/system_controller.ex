defmodule StockAlertWeb.SystemController do
  use StockAlertWeb, :controller

  def observe(conn, _param) do
    data =
      :observer.start()
      |> case do
        :ok -> "observer start successfully!!"
        _ -> "observer has already open!!"
      end

    json(put_status(conn, 200), %{data: data})
  end

  def total_process(conn, _param) do
    json(put_status(conn, 200), %{data: length(Process.list())})
  end

  def scheduler_usage(conn, _param) do
    [{:total, _, value} | _] = :scheduler.utilization(2)

    json(put_status(conn, 200), %{data: to_string(value)})
  end

  def top_high_reduction_process(conn, _param) do
    processes =
      :erlang.processes()
      |> Enum.map(fn process ->
        info = :erlang.process_info(process)

        %{
          reductions: info[:reductions],
          name: info[:registered_name],
          current_function: Tuple.to_list(info[:current_function])
        }
      end)
      |> Enum.sort(&(&1[:reductions] >= &2[:reductions]))
      |> Enum.take(5)

    json(put_status(conn, 200), %{data: processes})
  end
end
