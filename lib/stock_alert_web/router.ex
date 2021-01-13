defmodule StockAlertWeb.Router do
  use StockAlertWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StockAlertWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/users", UserController, only: [:index, :show]
    get "/system", SystemController, :observe
    get "/system/process", SystemController, :total_process
    get "/system/scheduler_usage", SystemController, :scheduler_usage
    get "/system/top_high_reduction_process", SystemController, :top_high_reduction_process
  end

  # Other scopes may use custom stacks.
  # scope "/api", StockAlertWeb do
  #   pipe_through :api
  # end
end
