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
end
