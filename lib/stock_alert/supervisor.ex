defmodule StockAlert.Supervisor do
  use DynamicSupervisor

  alias StockAlert.Worker

  @registry :workers_registry

  def start_link(_arg),
    do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_worker(user_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      %{
        id: Worker,
        start: {Worker, :start_link, [user_name, via_tuple(user_name)]},
        restart: :transient
      }
    )
    |> case do
      {:ok, pid} -> {:ok, pid}
      {:ok, pid, _info} -> {:ok, pid}
      others -> others
    end
  end

  def get_worker(name) do
    Registry.lookup(@registry, name)
    |> case do
      [] -> nil
      [{pid, _}] -> {:ok, pid}
    end
  end

  def stop_worker(pid) do
    GenServer.stop(pid, :normal)
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry, name}}
  end
end
