defmodule Thebex.Behaviour do
  @callback login(String.t, String.t) :: {:error, :invalid_username_or_password} | {:ok, String.t}
  @callback customers(String.t, non_neg_integer, non_neg_integer, Keyword.t) :: Schema.PageData.t
  @callback users(String.t, non_neg_integer, non_neg_integer, Keyword.t) :: Schema.PageData.t
  @callback customer_title(String.t, String.t) :: String.t
  @callback customer_devices(String.t, String.t, non_neg_integer, non_neg_integer, Keyword.t) :: Schema.PageData.t()
  @callback entity_timeseries(String.t, Schema.EntityId.t, Keyword.t) :: any
  @callback entity_latest_timeseries(String.t, Schema.EntityId.t, Keyword.t) :: any
end
