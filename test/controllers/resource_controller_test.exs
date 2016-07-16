require IEx
defmodule PcdmApi.ResourceControllerTest do
  use PcdmApi.ConnCase, async: true
  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
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

    assert hd(result["included"])["relationships"]["members"]["data"] == nil
  end

  test "GET /objects/1/relationships/members", %{conn: conn} do
    {:ok, resource} = Repo.insert(%Resource{model_name: "ScannedResource"})

    conn = get conn, "/objects/#{resource.id}/relationships/members"
    result = json_response(conn, 200)

    assert result["data"] == []
    assert result["links"]["self"] == "/objects/#{resource.id}/relationships/members"
  end

  test "POST /objects", %{conn: conn} do
    {:ok, resource} = Repo.insert(%Resource{model_name: "ScannedResource"})

    data = %{
      "type" => "objects",
      "attributes" => %{
        "@context" => %{},
        "title" => ["Ember Hamster"],
      },
      "relationships" => %{
        "members" => %{
          "data" => %{ "type" => "objects", "id" => "#{resource.id}" }
        }
      }
    }
    conn =
      conn
      |> post("/objects", Poison.encode!(%{"data" => data}))
    result = json_response(conn, 201)
    resource = Repo.get(Resource, result["data"]["id"]) |> Repo.preload(:members)
    assert length(resource.members) == 1
    assert result["data"]["id"]
    assert result["data"]["relationships"]["members"]["data"]
  end

  test "POST /objects with a bad ID", %{conn: conn} do
    data = %{
      "type" => "objects",
      "attributes" => %{
        "@context" => %{},
        "title" => ["Ember Hamster"],
      },
      "relationships" => %{
        "members" => %{
          "data" => [
            %{ "type" => "objects", "attributes" => %{"@context" => %{}}},
            %{ "type" => "objects", "id" => "100" },
          ]
        }
      }
    }
    conn =
      conn
      |> post("/objects", Poison.encode!(%{"data" => data}))
    result = json_response(conn, 422)
    assert length(Repo.all(from p in Resource)) == 0
  end

  test "POST /objects and create nested members", %{conn: conn} do
    data = %{
      "type" => "objects",
      "attributes" => %{
        "@context" => %{},
        "title" => ["Ember Hamster"],
      },
      "relationships" => %{
        "members" => %{
          "data" => %{ "type" => "objects", "attributes" => %{"title" =>
              ["Test"], "@context" => %{}} }
        }
      }
    }
    conn =
      conn
      |> post("/objects", Poison.encode!(%{"data" => data}))
    result = json_response(conn, 201)
    resource = Repo.get(Resource, result["data"]["id"]) |> Repo.preload(:members)
    assert length(resource.members) == 1
    assert result["data"]["id"]
    assert result["data"]["relationships"]["members"]["data"]
  end

  test "POST /objects and both create/link nested members", %{conn: conn} do
    {:ok, resource} = Repo.insert(%Resource{model_name: "ScannedResource"})
    data = %{
      "type" => "objects",
      "attributes" => %{
        "@context" => %{},
        "title" => ["Ember Hamster"],
      },
      "relationships" => %{
        "members" => %{
          "data" => [
            %{ "type" => "objects", "attributes" => %{"title" =>
              ["Test"], "@context" => %{}} },
          %{"type" => "objects", "id" => resource.id}
        ]
        }
      }
    }
    conn =
      conn
      |> post("/objects", Poison.encode!(%{"data" => data}))
    result = json_response(conn, 201)
    assert result["data"]["id"]
    resource = Repo.get(Resource, result["data"]["id"]) |> Repo.preload(:members)
    assert length(resource.members) == 2
    assert result["data"]["relationships"]["members"]["data"]
  end

  test "POST /objects without a context", %{conn: conn} do
    data = %{
      "type" => "objects",
      "attributes" => %{
        "title" => ["Ember Hamster"],
      }
    }

    conn =
      conn
      |> post("/objects", Poison.encode!(%{"data" => data}))
    result = json_response(conn, 422)
    assert %{"title" => "must have an @context key", "source" => %{"pointer" =>
        "/data/attributes/metadata"}} = hd(result["errors"])
  end
end
