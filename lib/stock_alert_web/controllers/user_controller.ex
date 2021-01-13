defmodule StockAlertWeb.UserController do
  use StockAlertWeb, :controller

  alias StockAlert.Manager

  def index(conn, _params) do
    users = Manager.list_users()
    render(conn, "users.json", %{data: users})
  end

  def show(conn, %{"id" => user_id}) do
    with user when not is_nil(user) <- Manager.get_user(user_id) do
      conn
      |> put_status(200)
      |> render("user.json", %{data: user})
    else
      nil ->
        # conn
        # |> put_status(422)
        # |> put_view(StockAlertWeb.ErrorView)
        # |> render(:"422")
        conn
        |> put_status(422)
        |> json(%{data: "user not found !!"})
    end
  end
end
