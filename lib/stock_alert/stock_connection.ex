defmodule StockAlert.StockConnection do
  use WebSockex

  def start_link({url, state}) do
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

    # |> IO.inspect()

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.inspect("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end
end
