defmodule PcdmApi.PostgresPersisterTest do
  use PcdmApi.ConnCase, async: true
  alias PcdmApi.PostgresPersister
  setup do
    {:ok, resource_params: %{"model_name" => "ScannedResource"}}
  end

  test "persisting a blank resource", %{resource_params: params} do
    {:ok, %{id: _}} = PostgresPersister.persist(params)
  end

  test "persisting a resource with metadata" do
    params = %{
      "model_name" => "ScannedResource",
      "metadata" => %{
        "type" => [%{"@id" => "http://test.com/type"}]
      }
    }
    {:ok, %{id: _}} = PostgresPersister.persist(params)
  end

  test "persisting a resource with a member" do
    params = %{
      "model_name" => "ScannedResource",
      "members" => [
        %{
          "model_name" => "ScannedResource"
        }
      ]
    }

    {:ok, %{id: _}} = PostgresPersister.persist(params)
    resources = Repo.all(from p in Resource, where: p.model_name == "ScannedResource")
    assert length(resources) == 2
  end

  test "persisting a resource with an ID as a member" do
    {:ok, resource} = PostgresPersister.persist(%{"model_name" => "Test"})
    params = %{
      "model_name" => "ScannedResource",
      "members" => [
        %{
          "id" => resource.id
        }
      ]
    }

    {:ok, new_resource} = PostgresPersister.persist(params)

    assert new_resource.members == [resource]
  end

  test "persisting a resource with existing IDs and new ones" do
    {:ok, resource} = PostgresPersister.persist(%{"model_name" => "Test"})
    params = %{
      "model_name" => "ScannedResource",
      "members" => [
        %{
          "id" => resource.id
        },
        %{
          "model_name" => "ScannedResource"
        }
      ]
    }

    {:ok, new_resource} = PostgresPersister.persist(params)

    assert length(new_resource.members) == 2
  end

  test "persisting a resource with explicit proxies" do
    {:ok, resource} = PostgresPersister.persist(%{"model_name" => "Test"})
    params = %{
      "model_name" => "ScannedResource",
      "member_proxies" => [
        %{
          "proxy_for_id" => resource.id
        }
      ]
    }

    {:ok, new_resource} = PostgresPersister.persist(params)

    assert (new_resource |> Repo.preload(:members)).members== [resource]
  end

  test "1000 proxies" do
    Benchwarmer.benchmark(fn ->
      {:ok, resource} = PostgresPersister.persist(%{"model_name" => "Test"})
      params = %{
        "model_name" => "ScannedResource",
        "member_proxies" => 
      Enum.map(0..1000, fn(_)->
        %{
          "proxy_for_id" => resource.id
        }
      end)
    }

    {:ok, new_resource} = PostgresPersister.persist(params)
    (new_resource |> Repo.preload(:members)).members
    end)
  end
end
