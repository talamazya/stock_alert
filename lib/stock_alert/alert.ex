defmodule StockAlert.Alert do
  alias __MODULE__

  defstruct [
    :code,
    :comparison,
    :field,
    :value
  ]

  def to_struct(alert) do
    struct(Alert, alert)
  end

  def equal?(alert1, alert2) do
    Map.equal?(Map.from_struct(alert1), Map.from_struct(alert2))
  end

  def insert(alerts, alert) do
    Enum.find(alerts, fn x -> equal?(x, alert) end)
    |> case do
      nil -> [alert | alerts]
      _ -> alerts
    end
  end

  def remove(alerts, alert) do
    Enum.find(alerts, fn x -> equal?(x, alert) end)
    |> case do
      nil -> alerts
      idx -> List.delete_at(alerts, idx)
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
