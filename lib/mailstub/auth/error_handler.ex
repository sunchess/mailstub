defmodule Mailstub.Auth.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, {_type, _reason}, _opts) do
    message = %{
      status: :unauthorized,
      message: "authentication failed!"
    }
    send_resp(conn, 401, Poison.encode!(message))
  end
end
