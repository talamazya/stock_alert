defmodule StockAlert.Manager do
  use GenServer
  require Logger

  alias StockAlert.Worker
  alias StockAlert.Supervisor

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    Logger.info("Starting Manager process #{inspect(state)}")

    stock_user = :ets.new(:stock_user_mapping, [:named_table])
    user_stock = :ets.new(:user_stock_mapping, [:named_table])
    state = Map.merge(state, %{stock_user_mapping: stock_user, user_stock_mapping: user_stock})

    {:ok, state}
  end

  # user setting
  def add_alerts(user, alerts) do
    Enum.each(alerts, &add_alert(user, &1))
  end

  def add_alert(user, alert) do
    GenServer.call(__MODULE__, {:add_alert, user, alert})
  end

  def remove_alert(user, alert) do
    GenServer.cast(__MODULE__, {:remove_alert, user, alert})
  end

  def remove_user(user) do
    GenServer.cast(__MODULE__, {:remove_user, user})
  end

  def list_users() do
    GenServer.call(__MODULE__, :list_users)
  end

  # stocks
  def process_stocks(%{list: stocks}) do
    GenServer.cast(__MODULE__, {:process_stocks, stocks})
  end

  def process_stocks(_), do: nil

  def handle_cast({:remove_alert, user, alert}, state) do
    {:ok, pid} = Supervisor.get_worker(user) || {:ok, nil}

    if pid, do: Worker.remove_alert(pid, alert)

    {:noreply, state}
  end

  def handle_cast({:remove_user, user}, state) do
    {:ok, pid} = Supervisor.get_worker(user) || {:ok, nil}
    handle_remove_user(user, pid)

    {:noreply, state}
  end

  def handle_cast({:process_stocks, stocks}, state) do
    Enum.each(stocks, &process_stock(&1))

    {:noreply, state}
  end

  def handle_call({:add_alert, user, %{code: code} = alert}, _from, state) do
    insert_ets(:user_stock_mapping, user, code)
    insert_ets(:stock_user_mapping, code, user)

    {:ok, pid} = Supervisor.get_worker(user) || Supervisor.start_worker(user)
    Worker.add_alert(pid, alert)

    {:reply, :ok, state}
  end

  def handle_call(:list_users, _from, state) do
    users =
      :ets.tab2list(:user_stock_mapping)
      |> Enum.into(%{}, fn {user, stocks} -> {user, MapSet.to_list(stocks)} end)

    {:reply, users, state}
  end

  defp insert_ets(table, key, value) do
    :ets.lookup(table, key)
    |> case do
      [] ->
        :ets.insert(table, {key, MapSet.new([value])})

      [{^key, values}] ->
        :ets.insert(table, {key, MapSet.put(values, value)})
    end
  end

  defp handle_remove_user(user, nil), do: user

  defp handle_remove_user(user, pid) do
    :ets.lookup(:user_stock_mapping, user)
    |> case do
      [] ->
        []

      [{^user, stocks}] ->
        Enum.each(stocks, fn stock ->
          :ets.lookup(:stock_user_mapping, stock)
          |> case do
            [] ->
              []

            [{^stock, users}] ->
              new_users = List.delete(users, user)
              :ets.insert(:stock_user_mapping, new_users)
          end
        end)

        :ets.delete(:user_stock_mapping, user)
    end

    Supervisor.stop_worker(pid)
  end

  defp process_stock(%{Code: code} = stock) do
    with [{^code, users}] <- :ets.lookup(:stock_user_mapping, code) do
      Enum.each(users, &transfer_to_worker(&1, stock))
    end
  end

  defp transfer_to_worker(user, stock) do
    {:ok, pid} = Supervisor.get_worker(user) || {:ok, nil}

    if pid do
      Worker.process_stock(pid, stock)
    else
      Logger.error("cannot find worker for user: #{inspect(user)} and stock: #{inspect(stock)}")
    end
  end
end
