defmodule Thebex.Parser do
  @moduledoc """
  Functions for parsing JSON objects and returning `Thebex.Schema`s.
  """
  alias Thebex.Schema

  @spec to_schema(map, any, map) :: any
  def to_schema(object, schema, renames \\ %{}) do
    # This forces Elixir to create the atoms for the schema's field names.
    # Otherwise the following call to `String.to_existing_atom()` will fail
    # for the first object of each schema.
    _unused_object = struct(schema)
    struct(
      schema,
      Map.new(
        object,
        # Apply renames in the keys (if any) and convert them to atoms.
        fn {k, v} -> {Map.get(renames, k, k) |> String.to_existing_atom(), v} end
      )
    )
  end

  def parse_entity_id(nil), do: nil

  @spec parse_entity_id(map) :: Schema.EntityId.t
  def parse_entity_id(object) do
    object
    |> to_schema(Schema.EntityId, %{"entityType" => "entity_type"})
  end

  @spec parse_user(map) :: Schema.User.t
  def parse_user(object) do
    renames = %{
      "createdTime" => "created_time",
      "tenantId" => "tenant_id",
      "customerId" => "customer_id",
      "firstName" => "first_name",
      "lastName" => "last_name",
      "additionalInfo" => "additional_info"
    }
    user = object |> to_schema(Schema.User, renames)
    %Schema.User{
      user |
      id: parse_entity_id(user.id),
      tenant_id: parse_entity_id(user.tenant_id),
      customer_id: parse_entity_id(user.customer_id)
    }
  end

  @spec parse_customer(map) :: Schema.Customer.t
  def parse_customer(object) do
    renames = %{
      "createdTime" => "created_time",
      "tenantId" => "tenant_id",
      "additionalInfo" => "additional_info"
    }
    customer = object |> to_schema(Schema.Customer, renames)
    %Schema.Customer{
      customer |
      id: parse_entity_id(customer.id),
      tenant_id: parse_entity_id(customer.tenant_id)
    }
  end

  @spec parse_device(map) :: Schema.Device.t
  def parse_device(object) do
    renames = %{
      "createdTime" => "created_time",
      "tenantId" => "tenant_id",
      "customerId" => "customer_id",
      "deviceProfileId" => "device_profile_id",
      "deviceData" => "device_data",
      "firmwareId" => "firmware_id",
      "softwareId" => "software_id",
      "additionalInfo" => "additional_info"
    }
    device = object |> to_schema(Schema.Device, renames)
    %Schema.Device{
      device |
      id: parse_entity_id(device.id),
      tenant_id: parse_entity_id(device.tenant_id),
      customer_id: parse_entity_id(device.customer_id),
      device_profile_id: parse_entity_id(device.device_profile_id),
      device_data: parse_device_data(device.device_data),
      firmware_id: parse_entity_id(device.firmware_id),
      software_id: parse_entity_id(device.software_id)
    }
  end

  @spec parse_device_data(map) :: Schema.DeviceData.t
  def parse_device_data(object) do
    renames = %{
      "transportConfiguration" => "transport_configuration"
    }
    object |> to_schema(Schema.DeviceData, renames)
  end

  @spec parse_page_data(map, any) :: Schema.PageData.t
  def parse_page_data(object, data_schema) do
    renames = %{
      "totalPages" => "total_pages",
      "totalElements" => "total_elements",
      "hasNext" => "has_next"
    }
    page_data = object |> to_schema(Schema.PageData, renames)
    parsing_functions = %{
      Schema.User => &parse_user/1,
      Schema.Customer => &parse_customer/1,
      Schema.Device => &parse_device/1
    }
    %Schema.PageData{
      page_data |
      data: page_data.data |> Enum.map(Map.fetch!(parsing_functions, data_schema))
    }
  end

  @spec parse_timeseries(map) :: map
  def parse_timeseries(object) do
    Map.map(
      object,
      fn {_key, datapoints} -> Enum.map(datapoints, &(to_schema(&1, Schema.DataPoint))) end
    )
  end

  @spec parse_latest_timeseries(map) :: map
  def parse_latest_timeseries(object) do
    object
    |> Map.map(fn {_key, [datapoint]} -> datapoint |> to_schema(Schema.DataPoint) end)
  end
end
