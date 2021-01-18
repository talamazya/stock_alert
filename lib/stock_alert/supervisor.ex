defmodule StockAlert.Supervisor do
  use DynamicSupervisor

  alias StockAlert.Worker
  alias StockAlert.Application

  def start_link(_arg),
    do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_worker(%{id: user_id} = user) do
    DynamicSupervisor.start_child(
      __MODULE__,
      %{
        id: Worker,
        start: {Worker, :start_link, [user, via_tuple(user_id)]},
        restart: :transient
      }
    )
    |> case do
      {:ok, pid} -> {:ok, pid}
      {:ok, pid, _info} -> {:ok, pid}
      others -> others
    end
  end

  def get_worker(user_id) do
    Registry.lookup(Application.registry(), user_id)
    |> case do
      [] -> nil
      [{pid, _}] -> {:ok, pid}
    end
  end

  def stop_worker(pid) do
    GenServer.stop(pid, :normal)
  end

  defp via_tuple(user_id) do
    {:via, Registry, {Application.registry(), user_id}}
  end
end
