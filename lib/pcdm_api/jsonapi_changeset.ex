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

  defp build_member(data, %{"data" => %{"type" => "objects", "id" => id}}) do
    data
    |> Map.put("member_proxies", [%{"proxy_for_id" => id}])
  end
end
