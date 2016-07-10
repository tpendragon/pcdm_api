defmodule PcdmApi.Repo.Migrations.ResourcesIndex do
  use Ecto.Migration

  def change do
    create index(:resources, [:model_name])
  end
end
