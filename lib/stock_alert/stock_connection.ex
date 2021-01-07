defmodule StockAlert.StockConnection do
  use WebSockex

  alias StockAlert.Manager

  def start_link({url, state}) do
    # will be remove later !!!!
    mock_process_frame()

    WebSockex.start_link(url, __MODULE__, state)
  end

  def init(state) do
    IO.inspect("[#{__MODULE__}][init] state=#{inspect(state)}")
    {:ok, state}
  end

  def handle_frame({_type, msg}, state) do
    # IO.inspect "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    msg
    |> Poison.decode!()

    # |> process_frame()

    # |> IO.inspect()

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.inspect("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  defp process_frame(_frame) do
    # done later. Wait for other server !!!
  end

  defp mock_process_frame() do
    mocked_frame = %{
      list: [
        %{
          ID: "11942269",
          High: "50",
          Volume: "892",
          Change: "0",
          Low: "49.55",
          PctChange: "-0.1996",
          Open: "49.55",
          Price: "50",
          Date: "18/11/2020 12:21:43",
          Code: "A1AP34"
        },
        %{
          ID: "11942964",
          High: "27.91",
          Volume: "121895650",
          Change: "0",
          Low: "26.97",
          PctChange: "1.98895",
          Open: "27.21",
          Price: "27.69",
          Date: "18/11/2020 15:44:31",
          Code: "TOTS3"
        }
      ]
    }

    Manager.process_stocks(mocked_frame)
  end
end
