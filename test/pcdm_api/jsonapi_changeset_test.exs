require IEx
defmodule JsonAPIChangesetTest do
  use PcdmApi.ModelCase
  alias PcdmApi.JSONAPIChangeset

  test "JsonAPIChangesetTest" do
    {:ok, resource} = Repo.insert(%Resource{})
    data = %{
      "type" => "objects",
      "attributes" => %{
        "title" => ["Ember Hamster"],
      },
      "relationships" => %{
        "members" => %{
          "data" => %{ "type" => "objects", "id" => "#{resource.id}" }
        }
      }
    }

    changeset = JSONAPIChangeset.changeset(%Resource{}, data)
    assert changeset.changes.metadata["title"] == ["Ember Hamster"]
    assert hd(changeset.changes.member_proxies).changes == %{proxy_for_id: resource.id}
  end
end
