require IEx
defmodule PcdmApi.ResourceController do
  use PcdmApi.Web, :controller
  plug JSONAPI.QueryParser, view: PcdmApi.ResourceView

  def show(conn = %{assigns: %{jsonapi_query: config}}, %{"id" => id}) do
    data = 
      Repo.get(Resource, id)
      |> Repo.preload(config.includes)
    conn
    |> render(data: data)
  end

  def create(conn, %{"data" => data}) do
    changeset = JSONAPIChangeset.changeset(%Resource{}, data)
    case Repo.insert(changeset) do
      {:ok, resource} ->
        conn
        |> put_status(201)
        |> render(data: resource |> Repo.preload(:members))
      {:error, changeset} -> 
        conn
        |> put_status(422)
        |> render(:errors, data: changeset)
    end
  end
end
