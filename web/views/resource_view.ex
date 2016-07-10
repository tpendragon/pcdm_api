require IEx
defmodule PcdmApi.ResourceView do
  use PcdmApi.Web, :view

  def render("create.json", %{resource: resource}) do
    IEx.pry
    resource
  end
end
