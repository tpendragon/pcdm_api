defmodule PcdmApi.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :model_name, :string
      add :metadata, :map

      timestamps
    end
  end
end
