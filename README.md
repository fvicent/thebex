# Thebex

Thebex is an Elixir client for the ThingsBoard REST API.

## Work in progress

This is a work in progress, though usable, not yet stable. There are no tests. Expect things to change. A few endpoints have been implemented (see below). Feel free to contribute your own endpoints.

## Installation

Thebex is not available in Hex yet, so it needs to be installed from this repository.

## Configuration

The API URL must be configured in your `config.exs`. For example:

```elixir
config :thebex, :thingsboard_api_url, "https://demo.thingsboard.io/api/"
```

If you just want to test the API via `iex`, you can manually configure the URL by using:

```elixir
iex(1)> Application.put_env(:thebex, :thingsboard_api_url, "https://demo.thingsboard.io/api/")
:ok
```

## Endpoints

Currently available endpoints:

  - `Thebex.login(username, password)`

  - `Thebex.customers(token, page, page_size, params \\ [])`

  - `Thebex.users(token, page, page_size, params \\ [])`

  - `Thebex.customer_title(token, customer_id)`

  - `Thebex.customer_devices(token, customer_id, page, page_size, params \\ [])`

  - `Thebex.entity_timeseries(token, entity, params \\ [])`

  - `Thebex.entity_latest_timeseries(token, entity, params \\ [])`

The supported `params` are mainly those documented in [Swagger](https://demo.thingsboard.io/swagger-ui/#/). See the [`lib/thebex/client.ex`](https://github.com/fvicent/thebex/blob/main/lib/thebex/client.ex) file for further insight. 

## Examples

First login to get a token to access the API:

```elixir
iex(1)> {:ok, token} = Thebex.login("myaccount@example.com", "password123")
{:ok, "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJmcmFuY2lzY..."}
```

Then every function from the API will require this token as its first argument.

```elixir
# Get the latest telemetry from a single device.
iex(2)> device = %Thebex.Schema.EntityId{entity_type: "DEVICE", id: "a4377650..."}
# Endpoint reference at
# https://demo.thingsboard.io/swagger-ui/#/telemetry-controller/getLatestTimeseriesUsingGET
iex(3)> Thebex.entity_latest_timeseries(token, device)
%{
  "humidity" => %Thebex.Schema.DataPoint{ts: 1642986254092, value: 90},
  "temperature" => %Thebex.Schema.DataPoint{ts: 1642986254092, value: 28}
}
```
