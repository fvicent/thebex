defmodule Thebex.Client do
  @moduledoc """
  HTTPoison-based implementation for the Thingsboard REST API.
  """
  alias Thebex.UnexpectedResponseError
  alias Thebex.Schema
  alias Thebex.Parser

  require Jason
  require HTTPoison

  import Thebex.HTTP

  defp get_base_url() do
    Application.fetch_env!(:thebex, :thingsboard_api_url)
  end

  defp process_params(params, supported_params) do
    params
    |> Enum.map(fn {k, v} -> {Keyword.fetch!(supported_params, k), v} end)
    |> Map.new()
  end

  defp process_response(response = %HTTPoison.Response{status_code: 200}) do
    response.body
  end

  defp process_response(response = %HTTPoison.Response{status_code: status_code, body: body}) do
    raise(UnexpectedResponseError, message: "[#{status_code}] #{body}", response: response)
  end

  defp get_page_data(url, token, schema, page, page_size, params) do
    supported_params = [
      sort_order: "sortOrder",
      sort_property: "sortProperty",
      text_search: "textSearch"
    ]
    page_params = %{
      "pageSize" => Integer.to_string(page_size),
      "page" => Integer.to_string(page)
    }
    params =
      params
      |> process_params(supported_params)
      |> Map.merge(page_params)
    request = create_request()
    response =
      request
      |> authorize(token)
      |> put_params(params)
      |> get(url)
    response
    |> process_response()
    |> Jason.decode!()
    |> Parser.parse_page_data(schema)
  end

  @doc """
  POST /api/auth/login

  ## Reference
  https://demo.thingsboard.io/swagger-ui/#/login-endpoint/loginPost
  """
  @spec login(String.t, String.t) :: {:error, :invalid_username_or_password} | {:ok, String.t}
  def login(username, password) do
    url = "#{get_base_url()}auth/login"
    request = create_request()
    response =
      request
      |> put_body(Jason.encode!(%{username: username, password: password}))
      |> post(url)
    case response.status_code do
      200 ->
        %{"token" => token} = Jason.decode!(response.body)
        {:ok, token}
      401 ->
        {:error, :invalid_username_or_password}
      _ ->
        raise(UnexpectedResponseError, response: response)
    end
  end

  @doc """
  GET /api/customers

  ## Reference
  https://demo.thingsboard.io/swagger-ui/#/customer-controller/getCustomersUsingGET
  """
  @spec customers(String.t, non_neg_integer, non_neg_integer, Keyword.t) :: Schema.PageData.t
  def customers(token, page, page_size, params \\ []) do
    get_page_data(
      "#{get_base_url()}customers",
      token,
      Schema.Customer,
      page,
      page_size,
      params
    )
  end

  @doc """
  GET /api/users

  ## Reference
  https://demo.thingsboard.io/swagger-ui/#/user-controller/getUsersUsingGET
  """
  @spec users(String.t, non_neg_integer, non_neg_integer, Keyword.t) :: Schema.PageData.t
  def users(token, page, page_size, params \\ []) do
    get_page_data(
      "#{get_base_url()}users",
      token,
      Schema.User,
      page,
      page_size,
      params
    )
  end

  @doc """
  GET /api/customer/{customerId}/title

  ## Reference
  https://demo.thingsboard.io/swagger-ui/#/customer-controller/getCustomerTitleByIdUsingGET
  """
  @spec customer_title(String.t, String.t) :: String.t
  def customer_title(token, customer_id) do
    url = "#{get_base_url()}customer/#{customer_id}/title"
    request = create_request()
    response =
      request
      |> authorize(token)
      |> get(url)
    process_response(response)
  end

  @doc """
  GET /api/customer/{customerId}/devices

  ## Reference
  https://demo.thingsboard.io/swagger-ui/#/device-controller/getCustomerDevicesUsingGET
  """
  @spec customer_devices(String.t, String.t, non_neg_integer, non_neg_integer,
                         Keyword.t) :: Schema.PageData.t()
  def customer_devices(token, customer_id, page, page_size, params \\ []) do
    get_page_data(
      "#{get_base_url()}customer/#{customer_id}/devices",
      token,
      Schema.Device,
      page,
      page_size,
      params
    )
  end

  defp do_entity_timeseries(
    token,
    %Schema.EntityId{id: entity_id, entity_type: entity_type},
    params
  ) do
    supported_params = [
      agg: "agg",
      end_ts: "endTs",
      interval: "interval",
      keys: "keys",
      limit: "limit",
      order_by: "orderBy",
      start_ts: "startTs"
    ]
    params =
      params
      |> process_params(supported_params)
      |> Map.put("useStrictDataTypes", true)
    url = "#{get_base_url()}plugins/telemetry/#{entity_type}/#{entity_id}/values/timeseries"
    request = create_request()
    response =
      request
      |> authorize(token)
      |> put_params(params)
      |> get(url)
    response
    |> process_response()
    |> Jason.decode!()
  end

  @doc """
  GET /api/plugins/telemetry/{entityType}/{entityId}/values/timeseries

  ## Reference
  https://demo.thingsboard.io/swagger-ui/#/telemetry-controller/getTimeseriesUsingGET
  """
  @spec entity_timeseries(String.t, Schema.EntityId.t, Keyword.t) :: any
  def entity_timeseries(token, entity_id, params \\ []) do
    Parser.parse_timeseries(do_entity_timeseries(token, entity_id, params))
  end

  @doc """
  GET /api/plugins/telemetry/{entityType}/{entityId}/values/timeseries

  ## Reference
  https://demo.thingsboard.io/swagger-ui/#/telemetry-controller/getLatestTimeseriesUsingGET
  """
  @spec entity_latest_timeseries(String.t, Schema.EntityId.t, Keyword.t) :: any
  def entity_latest_timeseries(token, entity_id, params \\ []) do
    Parser.parse_latest_timeseries(do_entity_timeseries(token, entity_id, params))
  end
end
