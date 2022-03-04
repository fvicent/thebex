defmodule Thebex.Schema.PageData do
  @enforce_keys [:data, :total_pages, :total_elements, :has_next]
  defstruct [:data, :total_pages, :total_elements, :has_next]

  @type t :: %__MODULE__{
    data: any,
    total_pages: non_neg_integer,
    total_elements: non_neg_integer,
    has_next: boolean
  }
end

defmodule Thebex.Schema.EntityId do
  defstruct [:id, :entity_type]

  @type t :: %__MODULE__{
    id: String.t,
    entity_type: String.t
  }
end

defmodule Thebex.Schema.User do
  defstruct [
    :id,
    :created_time,
    :tenant_id,
    :customer_id,
    :email,
    :name,
    :authority,
    :first_name,
    :last_name,
    :additional_info
  ]

  @type t :: %__MODULE__{
    id: Thebex.Schema.EntityId.t,
    created_time: non_neg_integer,
    tenant_id: Thebex.Schema.EntityId.t,
    customer_id: Thebex.Schema.EntityId.t,
    email: String.t,
    name: String.t,
    authority: String.t,
    first_name: String.t,
    last_name: String.t,
    additional_info: any
  }
end

defmodule Thebex.Schema.Customer do
  defstruct [
    :id,
    :created_time,
    :title,
    :name,
    :tenant_id,
    :country,
    :state,
    :city,
    :address,
    :address2,
    :zip,
    :phone,
    :email,
    :additional_info
  ]

  @type t :: %__MODULE__{
    id: Thebex.Schema.EntityId.t,
    created_time: non_neg_integer,
    title: String.t,
    name: String.t,
    tenant_id: Thebex.Schema.EntityId.t,
    country: String.t,
    state: String.t,
    city: String.t,
    address: String.t,
    address2: String.t,
    zip: String.t,
    phone: String.t,
    email: String.t,
    additional_info: any
  }
end

defmodule Thebex.Schema.Device do
  defstruct [
    :id,
    :created_time,
    :tenant_id,
    :customer_id,
    :name,
    :type,
    :label,
    :device_profile_id,
    :device_data,
    :firmware_id,
    :software_id,
    :additional_info
  ]

  @type t :: %__MODULE__{
    id: Thebex.Schema.EntityId.t,
    created_time: non_neg_integer,
    tenant_id: Thebex.Schema.EntityId.t,
    customer_id: Thebex.Schema.EntityId.t,
    name: String.t,
    type: String.t,
    label: String.t,
    device_profile_id: Thebex.Schema.EntityId.t,
    device_data: Thebex.Schema.DeviceData.t,
    firmware_id: Thebex.Schema.EntityId.t,
    software_id: Thebex.Schema.EntityId.t,
    additional_info: any
  }
end

defmodule Thebex.Schema.DeviceData do
  defstruct [:configuration, :transport_configuration]

  @type t :: %__MODULE__{
    configuration: any,
    transport_configuration: any
  }
end

defmodule Thebex.Schema.DataPoint do
  defstruct [:ts, :value]

  @type t :: %__MODULE__{
    ts: non_neg_integer,
    value: float
  }
end
