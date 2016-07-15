require IEx
defmodule PcdmApi.ResourceSerializer do
  use JaSerializer

  location "/objects/:id"

  def attributes(%{metadata: data}, conn) do
    data
  end
  def attributes(%{__struct__: Ecto.Association.NotLoaded}, _conn) do
    []
  end

  def relationships(resource, _conn) do
    %{
      members: JaSerializer.Relationship.HasMany.from_dsl(:members,
        links: [
          related: "/objects/:id/members",
          self: "/objects/:id/relationships/members"
        ],
        serializer: PcdmApi.ResourceSerializer,
        include: include_members(resource)
      )
    }
  end
  def relationships(_, _), do: %{}

  def include_members(%{members: members}) when is_list(members), do: true
  def include_members(_), do: false

  def members(%{members: members}, _conn) do
    members
  end
  def members(_, _), do: nil
end
