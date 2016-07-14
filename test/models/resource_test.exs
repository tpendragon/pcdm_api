defmodule PcdmApi.ResourceTest do
  use PcdmApi.ModelCase, async: true
  test "members" do
    {:ok, parent} = Repo.insert(%Resource{model_name: "Test"})
    {:ok, resource} = Repo.insert(%Resource{model_name: "Test"})
    {:ok, proxy} = Repo.insert(%MemberProxy{proxy_for_id: resource.id, proxy_in_id: parent.id})
    parent = Repo.preload(parent, :members)
    assert [resource] == parent.members
  end
end
