defmodule PcdmApi.PageController do
  use PcdmApi.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
