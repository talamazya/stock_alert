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
    %{field: field_name, value: alert_value, comparison: comparison} = alert

    with field_value when not is_nil(field_value) <- Map.get(stock, field_name),
         {true, result} <- compare(String.to_float(field_value), comparison, alert_value) do
      matched_alert =
        alert
        |> Map.from_struct()
        |> Map.put(:message, "#{alert.code} value is #{result} #{inspect(alert_value)}")

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
end
