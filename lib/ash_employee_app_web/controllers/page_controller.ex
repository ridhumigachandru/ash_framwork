defmodule AshEmployeeAppWeb.PageController do
  use AshEmployeeAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
