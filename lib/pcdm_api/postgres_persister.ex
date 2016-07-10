require IEx
defmodule PcdmApi.PostgresPersister do
  alias PcdmApi.Repo
  alias PcdmApi.Resource
  def persist(resource = %Ecto.Changeset{data: %Resource{}}) do
    Repo.insert(resource)
  end
  def persist(resource = %{"model_name" => _, "members" => members}) do
    Repo.transaction fn ->
      {:ok, resource} = 
        resource
        |> Map.drop(["members"])
        |> persist
      create_proxies(resource, members)
      Repo.preload(resource, :members)
    end
  end
  def persist(resource = %{"model_name" => _}) do
    persist(Resource.changeset(%Resource{}, resource))
  end
  def persist(resource = %{"id" => id}) do
    {:ok, Repo.get(Resource, id)}
  end

  defp create_proxies(resource, members) do
    members
    |> Enum.map(&create_proxy(resource, &1))
  end
  defp create_proxy(resource, member) do
    {:ok, member} = persist(member)
    {:ok, proxy} = Ecto.build_assoc(resource, :member_proxies, proxy_for_id: member.id)
    |> Repo.insert
    proxy
  end
end
