defmodule Thebex do
  @moduledoc """
  An Elixir implementation of the ThingsBoard REST API.
  """
  alias Thebex.Behaviour
  @behaviour Behaviour
  use Application

  @impl Application
  def start(_type, _args) do
    HTTPoison.start
  end

  @impl Behaviour
  defdelegate login(username, password), to: Thebex.Client, as: :login

  @impl Behaviour
  defdelegate customers(token, page, page_size, params \\ []), to: Thebex.Client, as: :customers

  @impl Behaviour
  defdelegate users(token, page, page_size, params \\ []), to: Thebex.Client, as: :users

  @impl Behaviour
  defdelegate customer_title(token, customer_id), to: Thebex.Client, as: :customer_title

  @impl Behaviour
  defdelegate customer_devices(token, customer_id, page, page_size, params \\ []), to: Thebex.Client, as: :customer_devices

  @impl Behaviour
  defdelegate entity_timeseries(token, entity, params \\ []), to: Thebex.Client, as: :entity_timeseries

  @impl Behaviour
  defdelegate entity_latest_timeseries(token, entity, params \\ []), to: Thebex.Client, as: :entity_latest_timeseries
end
