defmodule StockAlertWeb.PageController do
  use StockAlertWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
