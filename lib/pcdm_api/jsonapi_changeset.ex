require IEx
defmodule PcdmApi.JSONAPIChangeset do
  def changeset(resource, data) do
    resource.__struct__.changeset(resource, transform_data(data))
  end

  defp transform_data(data = %{"attributes" => attributes}) do
    data
    |> Map.drop(["attributes"])
    |> Map.put("metadata", attributes)
    |> transform_data
  end
  defp transform_data(data = %{"relationships" => %{"members" => members}}) do
    relationships = 
      data["relationships"]
      |> Map.drop(["members"])
    data
    |> Map.put("relationships", relationships)
    |> build_member(members)
    |> transform_data
  end
  defp transform_data(data), do: data

  defp build_member(data, %{"data" => members}) when is_list(members) do
    Enum.reduce(members, data, fn(member, d) -> build_member(d, %{"data" =>
      member}) end)
  end
  defp build_member(data, %{"data" => %{"type" => "objects", "id" => id}}) do
    data
    |> append_member_proxy(%{"proxy_for_id" => id})
  end
  defp build_member(data, %{"data" => member = %{"type" => "objects", "attributes" => attributes}}) do
    data
    |> append_member_proxy(%{"proxy_for" => transform_data(member)})
  end

  defp append_member_proxy(data = %{"member_proxies" => list}, member_data) do
    data
    |> Map.put("member_proxies", list ++ [member_data])
  end
  defp append_member_proxy(data, member_data) do
    data
    |> Map.put("member_proxies", [member_data])
  end
end
