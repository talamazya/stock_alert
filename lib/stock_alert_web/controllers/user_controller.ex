defmodule StockAlertWeb.UserController do
  use StockAlertWeb, :controller

  alias StockAlert.Manager

  def index(conn, _params) do
    users = Manager.list_users()
    render(conn, "users.json", %{data: users})
  end
end
