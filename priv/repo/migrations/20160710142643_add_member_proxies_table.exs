defmodule PcdmApi.Repo.Migrations.AddMemberProxiesTable do
  use Ecto.Migration

  def change do
    create table(:member_proxies) do
      add :proxy_for_id, references(:resources)
      timestamps
    end
  end
end
