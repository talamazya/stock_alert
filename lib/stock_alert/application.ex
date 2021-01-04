defmodule StockAlert.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @url "wss://stream.binance.com:9443/ws/bnbbtc@depth"
  @registry :workers_registry

  def start(_type, _args) do
    children = [
      StockAlertWeb.Endpoint,
      StockAlert.AlertClient,
      {Registry, [keys: :unique, name: @registry]},
      StockAlert.Supervisor,
      StockAlert.Manager,
      {StockAlert.UserConnection, {@url, %{}}},
      {StockAlert.StockConnection, {@url, %{}}}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    StockAlertWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def registry(), do: @registry
end
