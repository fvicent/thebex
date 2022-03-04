defmodule Thebex.UnexpectedResponseError do
  defexception [:response, message: "unexpected response"]
end
