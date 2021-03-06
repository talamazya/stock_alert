# StockAlert

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

To run demo (run unit test)
  * `mix test`

To run mocked version 
  * `iex -S mix phx.server`
  * `StockAlert.AlertClient.get_alert_from_queue()`

APIs
  * list all users:
    `curl -X GET http://localhost:4000/users`

  * get info of a user:
  `curl -X GET http://localhost:4000/users/Caio%20Borghi`

  * observe system:
  `curl -X GET http://localhost:4000/system`

  * get total process in system:
  `curl -X GET http://localhost:4000/system/process`

  * get schedule usage (instead of cpu usage) in BEAM:
  `curl -X GET http://localhost:4000/system/scheduler_usage`

  * get top high reduction process(top high calling function process):
  `curl -X GET http://localhost:4000/system/top_high_reduction_process`

Requirement doc:
  * `https://docs.google.com/document/d/1whHkyzLCX-ZzC7PcCsnBZaokxkCSb0T8501YlNtnOwo/edit`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
