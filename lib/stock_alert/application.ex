defmodule StockAlert.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @url "wss://stream.binance.com:9443/ws/bnbbtc@depth"

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      StockAlertWeb.Endpoint,
      # Starts a worker by calling: StockAlert.Worker.start_link(arg)
      # {StockAlert.Worker, arg},
      {StockAlert.Connection, {@url, %{}}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StockAlert.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    StockAlertWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
