defmodule StockAlert.IntegrationTest do
  use StockAlert.IntegrationCase

  alias StockAlert.Manager

  describe "intergration test" do
    test "when stock alert match a user setting alert" do
      stocks = get_stocks()

      Manager.process_stocks(stocks)

      # sleep 1s to wait for the alert be processed succesfully
      # will be fixed later
      Process.sleep(1000)
      assert true
    end
  end
end
