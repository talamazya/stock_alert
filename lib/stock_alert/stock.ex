defmodule StockAlert.Stock do
  alias __MODULE__

  defstruct [
    :code
  ]

  def to_struct(stock) do
    struct(Stock, stock)
  end

  def equal?(stock1, stock2) do
    Map.equal?(Map.from_struct(stock1), Map.from_struct(stock2))
  end

  def insert(stocks, stock) do
    Enum.find(stocks, fn x -> equal?(x, stock) end)
    |> case do
      nil -> [stock | stocks]
      _ -> stocks
    end
  end

  # def to_struct(stock) do
  #   stock = Enum.into(stock, %{}, fn {k, v} -> {Map.get(@socket_to_struct_key, k, k), v} end)
  #   struct(Stock, stock)
  # end
end

# {
#   code: "TOTS3",
#   comparison: ">",
#   field: "Close",
#   message: "TOTS3 value is higher than 80.70!",
#   value: 80.70
#   }
