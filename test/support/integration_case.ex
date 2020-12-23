defmodule StockAlert.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import StockAlert.IntegrationCase
    end
  end

  setup _tags do
    user1_name = "Caio Borghi"

    user1_setting = %{
      code: "TOTS3",
      comparison: ">",
      field: :Open,
      value: 25
    }

    StockAlert.Manager.add_alert(user1_name, user1_setting)
    {:ok, %{}}
  end

  def get_stocks() do
    StockDumpData.get_stocks()
  end
end
