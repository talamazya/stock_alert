defmodule StockAlertWeb.UserView do
  use StockAlertWeb, :view

  def render("users.json", %{data: users}) do
    %{data: users}
  end
end
