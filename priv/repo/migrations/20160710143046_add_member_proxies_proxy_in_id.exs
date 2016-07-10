defmodule PcdmApi.Repo.Migrations.AddMemberProxiesProxyInId do
  use Ecto.Migration

  def change do
    alter table(:member_proxies) do
      add :proxy_in_id, references(:resources)
    end
  end
end
