require IEx
defmodule PcdmApi.ResourceController do
  use PcdmApi.Web, :controller
  plug :apply_model_name
  plug :transform_model_name

  def create(conn, params) do
    case persister.persist(params["resource"]) do
      {:ok, result} ->
        conn
        |> put_status(201)
        |> render(resource: result)
    end
  end

  defp apply_model_name(conn = %{:params => %{"type" => type}}, _opts) do
    params =
      conn.params
      |> put_in(["resource"], conn.params["resource"] || %{})
      |> put_in(["resource", "model_name"], type)
    %{conn | params: params}
  end

  defp transform_model_name(conn = %{:params => %{"resource" => %{"model_name" => model_name}}}, _opts) do
    params =
      conn.params
      |> put_in(["resource", "model_name"], Macro.camelize(model_name))
    %{conn | params: params}
  end
  defp transform_model_name(conn, _), do: conn


  defp persister do
    PcdmApi.PostgresPersister
  end
end
