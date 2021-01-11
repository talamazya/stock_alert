defmodule StockAlertWeb.UserView do
  use StockAlertWeb, :view

  def render("users.json", %{data: users}) do
    %{data: render_many(users, __MODULE__, "user_page.json", as: :user)}
  end

  def render("user.json", %{data: user}) do
    %{data: render_one(user, __MODULE__, "user_page.json", as: :user)}
  end

  def render("user_page.json", %{user: user}) do
    user
  end
end
