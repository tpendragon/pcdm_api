require IEx
defmodule PcdmApi.ResourceView do
  use PcdmApi.Web, :view
  # use JaSerializer.PhoenixView

  def render("show.json-api", %{conn: conn, data: data}) do
    JaSerializer.format(PcdmApi.ResourceSerializer, data, conn)
  end
  def render("show.json", params), do: render("show.json-api", params)

  def render("create.json-api", params = %{data: data}) do
    render("show.json", params)
  end

  def render("errors.json-api", data) do
    JaSerializer.PhoenixView.render_errors(data)
  end

  def fields, do: []
  def type, do: "objects"
  def relationships, do: [members: PcdmApi.ResourceView]

  def attributes(%Resource{metadata: data}, conn) do
    Map.take(data, Map.keys(data))
  end
end
