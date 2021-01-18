defmodule StockAlert.AlertClient do
  use GenServer
  require Logger
  alias AMQP.Connection
  alias AMQP.Channel
  alias AMQP.Queue
  alias AMQP.Exchange
  alias AMQP.Basic

  @host "amqp://localhost"
  @reconnect_interval 10_000
  @queue "alert_queue"
  @exchange "alert_exchange"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {_, state} = connect_rabbitmq(%{})
    {:ok, state}
  end

  def send_alert(alert) do
    GenServer.cast(__MODULE__, {:send_alert, alert})
  end

  def get_connection do
    case GenServer.call(__MODULE__, :get) do
      nil -> {:error, :not_connected}
      conn -> {:ok, conn}
    end
  end

  def get_channel do
    case GenServer.call(__MODULE__, :get_channel) do
      nil -> {:error, :not_connected}
      chan -> {:ok, chan}
    end
  end

  # note. Just for testing, this function will be remove
  def get_alert_from_queue() do
    GenServer.cast(__MODULE__, :get_alert)
  end

  def handle_cast({:send_alert, alert}, %{chan: chan} = state) do
    # Basic.publish(chan, @exchange, "", inspect(alert))
    {:ok, encoded_alert} = JSON.encode(alert)

    Basic.publish(chan, @exchange, "", encoded_alert)

    {:noreply, state}
  end

  def handle_cast(:get_alert, %{chan: chan} = state) do
    with {:ok, payload, _meta} <- Basic.get(chan, @queue),
         {:ok, decoded_payload} <- JSON.decode(payload) do
      IO.inspect(decoded_payload, label: :alert_in_Rabbit_mq)
    end

    {:noreply, state}
  end

  def handle_call(:get_channel, _, %{chan: chan} = state) do
    {:reply, chan, state}
  end

  def handle_call(:get_channel, _, state) do
    {:reply, nil, state}
  end

  def handle_call(:get, _, %{conn: conn} = state) do
    {:reply, conn, state}
  end

  def handle_info(:connect, state) do
    connect_rabbitmq(state)
  end

  def handle_info({:DOWN, _, :process, _pid, reason}, _) do
    # Stop GenServer. Will be restarted by Supervisor.
    {:stop, {:connection_lost, reason}, nil}
  end

  defp connect_rabbitmq(state) do
    with {:ok, conn} <- Connection.open(@host),
         {:ok, chan} <- Channel.open(conn),
         {:ok, _} <- Queue.declare(chan, @queue),
         :ok <- Exchange.declare(chan, @exchange),
         :ok <- Queue.bind(chan, @queue, @exchange) do
      # Get notifications when the connection goes down
      Process.monitor(conn.pid)
      {:noreply, Map.merge(state, %{conn: conn, chan: chan})}
    else
      {:error, _} ->
        Logger.error("Failed to connect #{@host}. Reconnecting later...")
        # Retry later
        Process.send_after(self(), :connect, @reconnect_interval)
        {:noreply, state}
    end
  end
end
