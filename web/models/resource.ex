require IEx
defmodule PcdmApi.Resource do
  @derive {Poison.Encoder, except: [:__meta__, :member_proxies, :members]}
  use Ecto.Schema
  alias PcdmApi.MemberProxy
  import Ecto.Changeset
  schema "resources" do
    field :model_name, :string
    field :metadata, :map, default: %{}
    has_many :member_proxies, MemberProxy, foreign_key: :proxy_in_id
    has_many :members, through: [:member_proxies, :proxy_for]

    timestamps
  end

  def changeset(resource, params \\ %{}) do
    resource
    |> cast(params, [], [:metadata])
    |> cast_assoc(:member_proxies)
  end
end
