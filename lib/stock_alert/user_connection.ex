defmodule StockAlert.UserConnection do
  use WebSockex

  alias StockAlert.Manager

  def start_link({url, state}) do
    # will be removed later!!!
    mock_process_frame()

    WebSockex.start_link(url, __MODULE__, state)
  end

  def init(state) do
    IO.inspect("[#{__MODULE__}][init] state=#{inspect(state)}")

    {:ok, state}
  end

  def handle_frame({_type, msg}, state) do
    # IO.inspect "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    msg
    |> Poison.decode!()

    # |> process_frame()

    # |> IO.inspect()

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.inspect("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  defp process_frame(%{"action" => action, "data" => data}) do
    case action do
      :remove_alert -> remove_alert(data)
      :add_alert -> add_alerts(data)
      :remove_user -> remove_user(data)
    end
  end

  defp process_frame(frame) do
    IO.inspect(frame, label: :not_supported_frame)
  end

  defp remove_alert(%{userID: user_id, alertID: alert_id}) do
    Manager.remove_alert(user_id, alert_id)
  end

  defp remove_alert(data) do
    IO.inspect(data, label: :not_supported_remove_alert_data)
  end

  defp add_alerts(%{"user" => %{"id" => user_id, "alerts" => alerts}}) do
    Manager.add_alerts(user_id, alerts)
  end

  defp add_alerts(data) do
    IO.inspect(data, label: :not_supported_add_alert_data)
  end

  defp remove_user(%{"userID" => user_id}) do
    Manager.remove_user(user_id)
  end

  defp remove_user(data) do
    IO.inspect(data, label: :not_supported_remove_user_data)
  end

  # note: this function will be remove when I have a real data
  defp mock_process_frame() do
    mocked_name = "Caio Borghi"

    mocked_setting = %{
      code: "TOTS3",
      comparison: ">",
      field: :Open,
      value: 25
    }

    Manager.add_alert(mocked_name, mocked_setting)
  end
end
