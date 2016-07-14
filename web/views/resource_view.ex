require IEx
defmodule PcdmApi.ResourceView do
  use PcdmApi.Web, :view
  use JSONAPI.View

  def render("create.json", %{resource: resource}) do
    resource
  end

  def render("show.json", %{data: data, conn: conn}) do
    JSONAPI.Serializer.serialize(PcdmApi.ResourceView, data, conn)
  end

  def fields, do: []
  def type, do: "objects"
  def relationships, do: [members: PcdmApi.ResourceView]
end
