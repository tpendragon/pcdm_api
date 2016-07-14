require IEx
defmodule PcdmApi.ResourceControllerTest do
  use PcdmApi.ConnCase, async: true

  test "POST /resource/type", %{conn: conn} do
    conn = post conn, "/resource/scanned_resource"

    result = json_response(conn, 201)
    resources = Repo.all(from p in Resource, where: p.model_name == "ScannedResource")
    assert length(resources) == 1

    assert %{"id" => _} = result
  end

  test "GET /objects/1", %{conn: conn} do
    {:ok, resource} = Repo.insert(%Resource{model_name: "ScannedResource",
      metadata: %{stuff: ["things"]}})

    conn = get conn, "/objects/#{resource.id}"
    result = json_response(conn, 200)
    assert result["data"]["attributes"]["stuff"] == ["things"]
  end
  
  test "GET /objects/1?include=members", %{conn: conn} do
    {:ok, member} = Repo.insert(%Resource{model_name: "ScannedResource"})
    {:ok, resource} = Repo.insert(%Resource{model_name: "ScannedResource"})
    {:ok, proxy} = Repo.insert(Ecto.build_assoc(resource, :member_proxies, proxy_for_id: member.id))

    conn = get conn, "/objects/#{resource.id}?include=members"
    result = json_response(conn, 200)

    assert hd(result["included"])["relationships"]["members"]["data"] == []
  end
end
