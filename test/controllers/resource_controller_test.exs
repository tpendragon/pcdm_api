defmodule PcdmApi.ResourceControllerTest do
  use PcdmApi.ConnCase, async: true

  test "POST /resource/type", %{conn: conn} do
    conn = post conn, "/resource/scanned_resource"

    result = json_response(conn, 201)
    resources = Repo.all(from p in Resource, where: p.model_name == "ScannedResource")
    assert length(resources) == 1

    assert %{"id" => _} = result
  end
end
