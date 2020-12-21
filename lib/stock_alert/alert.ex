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

  def match_alert(alert, stock) do
    %{field: field_name, value: value, comparison: comparison} = alert

    with field_value when not is_nil(field_value) <- Map.get(stock, field_name),
         {true, result} <- compare(field_value, comparison, value) do
      matched_alert =
        alert
        |> Map.from_struct()
        |> Map.put(:message, "#{inspect(alert.code)} value is #{result} #{inspect(value)}")

      {:ok, matched_alert}
    else
      nil -> {:error, :not_match}
      {false, _} -> {:error, :not_match}
    end
  end

  defp compare(left, operator, right) do
    case operator do
      ">" -> {left > right, "higher than"}
      "<" -> {left < right, "lower than"}
      _ -> {left == right, "equal"}
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

# {
#   "ID": "11942270",
#   "High": "601.84",
#   "Volume": "120170",
#   "Change": "0",
#   "Low": "599.36",
#   "PctChange": "-2.40025",
#   "Open": "601.84",
#   "Price": "599.36",
#   "Date": "18/11/2020 15:11:43",
#   "Code": "A1LG34"
# },
