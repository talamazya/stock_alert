defmodule StockAlert.Worker do
  use GenServer
  require Logger

  alias StockAlert.Alert
  alias StockAlert.AlertClient

  ## API
  def start_link(user, process_name) do
    GenServer.start_link(__MODULE__, %{user: user, alerts: []}, name: process_name)
  end

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

    {:ok, state}
  end

  def handle_cast(:work, name) do
    Logger.info("hola")
    {:noreply, name}
  end

  def handle_cast(:raise, name) do
    raise(RuntimeError, message: "Error, Server #{name} has crashed")
  end

  def handle_cast({:process_stock, stock}, %{alerts: alerts, user: user} = state) do
    Enum.each(alerts, &handle_process_stock(&1, stock, user))

    {:noreply, state}
  end

  def handle_call({:add_alert, alert}, _from, %{alerts: alerts} = state) do
    state =
      state
      |> Map.put(:alerts, Alert.insert(alerts, Alert.to_struct(alert)))

    {:reply, :ok, state}
  end

  def handle_call({:remove_alert, alert}, _from, %{alerts: alerts} = state) do
    new_alerts = Alert.remove(alerts, alert)

    {:reply, :ok, Map.put(state, :alerts, new_alerts)}
  end

  def terminate(reason, name) do
    Logger.info("Exiting worker: #{name} with reason: #{inspect(reason)}")
  end

  defp handle_process_stock(%{code: code} = alert, %{Code: code} = stock, user) do
    with {:ok, matched_alert} <- Alert.match_alert(alert, stock),
         {:ok, rabbit_msg} <- build_rabbit_message(user, matched_alert) do
      # send matched_alert to RabitMQ

      AlertClient.send_alert(rabbit_msg)

      IO.inspect(
        "***********************************************************************************************"
      )

      IO.inspect("stock alert found !!!!!!!")
      IO.inspect(stock, label: :stock)
      IO.inspect(Map.from_struct(alert), label: :user_alert)
      IO.puts("\nMatched alert will be sent to RabitMQ")
      IO.inspect(matched_alert, label: :matched_alert)

      IO.inspect(
        "***********************************************************************************************"
      )
    end
  end

  defp handle_process_stock(_, _, _), do: nil

  defp build_rabbit_message(
         %{id: user_id, phone: phone},
         %{id: alert_id, message: msg}
       ) do
    rabbit_msg = %{
      userID: user_id,
      userPhone: phone,
      alertID: alert_id,
      message: msg
    }

    {:ok, rabbit_msg}
  end

  defp build_rabbit_message(_, _) do
    {:error, "something wrong in data !!!!"}
  end
end
