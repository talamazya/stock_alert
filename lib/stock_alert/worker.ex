defmodule StockAlert.Worker do
  use GenServer
  require Logger

  alias StockAlert.Alert

  ## API
  def start_link(name, process_name) do
    GenServer.start_link(__MODULE__, %{name: name, alerts: []}, name: process_name)
  end

  # def crash(name), do: GenServer.cast(via_tuple(name), :raise)

  def add_alert(pid, alert) do
    GenServer.call(pid, {:add_alert, alert})
  end

  def remove_alert(pid, alert) do
    GenServer.call(pid, {:remove_alert, alert})
  end

  def process_stock(pid, stock) do
    GenServer.cast(pid, {:process_stock, stock})
  end

  ## Callbacks
  def init(state) do
    Logger.info("Starting #{inspect(state)}")

    # :ets.new(stock_alert_mapping(), [:named_table])

    {:ok, state}
  end

  def handle_cast(:work, name) do
    Logger.info("hola")
    {:noreply, name}
  end

  def handle_cast(:raise, name) do
    raise(RuntimeError, message: "Error, Server #{name} has crashed")
  end

  def handle_cast({:process_stock, stock}, %{alerts: alerts} = state) do
    Enum.each(alerts, &handle_process_stock(&1, stock))

    {:noreply, state}
  end

  def handle_call({:add_alert, alert}, _from, state) do
    handle_add_alert(alert, state)

    {:reply, :ok, state}
  end

  def handle_call({:remove_alert, alert}, _from, %{alerts: alerts} = state) do
    new_alerts = Alert.remove(alerts, alert)

    {:reply, :ok, Map.put(state, :alerts, new_alerts)}
  end

  def terminate(reason, name) do
    Logger.info("Exiting worker: #{name} with reason: #{inspect(reason)}")
  end

  ## Private
  defp handle_add_alert(alert, %{alerts: alerts} = state) do
    Map.put(state, :alerts, Alert.insert(alerts, Alert.to_struct(alert)))
  end

  defp handle_process_stock(%{code: code} = alert, %{Code: code} = stock) do
    with {:ok, matched_alert} <- Alert.match_alert(alert, stock) do
      # send matched_alert to RabitMQ
      IO.inspect(matched_alert, label: :matched_alert)
    end
  end

  defp handle_process_stock(_, _), do: nil
end
