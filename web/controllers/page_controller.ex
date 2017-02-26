defmodule Chess.PageController do
  use Chess.Web, :controller

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    render conn, "index.html", user: user
  end
end
