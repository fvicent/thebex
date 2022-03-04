defmodule Thebex.HTTP.Request do
  defstruct [:url, :headers, :params, :body]

  @type t :: %__MODULE__{
    url: String.t,
    headers: list(tuple()),
    params: map,
    body: String.t
  }
end

defmodule Thebex.HTTP do
  @moduledoc """
  Quick wrapper around HTTPoison.
  """
  require HTTPoison

  @spec create_request :: Thebex.HTTP.Request.t
  @doc """
  Create an empty request for JSON data.
  """
  def create_request do
    struct(
      Thebex.HTTP.Request,
      %{
        headers: [{"Content-Type", "application/json"}],
        params: %{}
      }
    )
  end

  @doc """
  Set the authorization token into the request.
  """
  @spec authorize(Thebex.HTTP.Request.t, String.t) :: Thebex.HTTP.Request.t
  def authorize(%Thebex.HTTP.Request{headers: headers} = request, token) do
    %{
      request |
      headers: [{"X-Authorization", "Bearer #{token}"} | headers]
    }
  end

  @doc """
  Put the specified params into the request.
  """
  @spec put_params(Thebex.HTTP.Request.t, map) :: Thebex.HTTP.Request.t
  def put_params(%Thebex.HTTP.Request{params: current_params} = request, params) do
    %{
      request |
      params: Map.merge(current_params, params)
    }
  end

  @doc """
  Put the specified body into the request (for later POSTing).
  """
  @spec put_body(Thebex.HTTP.Request.t, String.t) :: Thebex.HTTP.Request.t
  def put_body(request, body), do: %{request | body: body}

  @doc """
  Make a GET request.
  """
  @spec get(Thebex.HTTP.Request.t, String.t) :: HTTPoison.Response.t
  def get(request, url) do
    HTTPoison.get!(
      url,
      request.headers,
      params: request.params
    )
  end

  @doc """
  Make a POST request.
  """
  @spec post(Thebex.HTTP.Request.t, String.t) :: HTTPoison.Response.t
  def post(request, url) do
    HTTPoison.post!(
      url,
      request.body,
      request.headers,
      params: request.params
    )
  end
end
