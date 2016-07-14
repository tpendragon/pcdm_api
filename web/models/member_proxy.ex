defmodule PcdmApi.MemberProxy do
  use Ecto.Schema
  import Ecto.Changeset
  alias PcdmApi.Resource
  schema "member_proxies" do
    belongs_to :proxy_for, Resource
    belongs_to :proxy_in, Resource

    timestamps
  end

  def changeset(resource, params \\ %{}) do
    resource
    |> cast(params, [:proxy_for_id], [])
  end
end
