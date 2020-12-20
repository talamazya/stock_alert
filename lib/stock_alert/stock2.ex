defmodule StockAlert.Stock2 do
  alias __MODULE__

  defstruct [
    :id,
    :high,
    :volume,
    :change,
    :low,
    :pctchange,
    :open,
    :price,
    :date,
    :code
  ]

  @socket_to_struct_key %{
    "ID" => :id,
    "High" => :high,
    "Volume" => :volume,
    "Change" => :change,
    "Low" => :low,
    "PctChange" => :pctchange,
    "Open" => :open,
    "Price" => :price,
    "Date" => :date,
    "Code" => :code
  }

  def to_struct(stock) do
    stock = Enum.into(stock, %{}, fn {k, v} -> {Map.get(@socket_to_struct_key, k, k), v} end)
    struct(Stock, stock)
  end
end
