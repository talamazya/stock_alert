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
  end

  # Other scopes may use custom stacks.
  # scope "/api", StockAlertWeb do
  #   pipe_through :api
  # end
end
