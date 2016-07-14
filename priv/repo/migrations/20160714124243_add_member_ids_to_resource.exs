defmodule PcdmApi.Repo.Migrations.AddMemberIdsToResource do
  use Ecto.Migration
  use Ecto.Schema

  def change do
    alter table(:resources) do
      add :member_ids, {:array, :integer}
    end
  end
end
