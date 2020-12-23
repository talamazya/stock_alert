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
end
