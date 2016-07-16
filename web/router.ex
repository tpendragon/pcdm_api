defmodule PcdmApi.Router do
  use PcdmApi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json-api"]
    plug JaSerializer.ContentTypeNegotiation
  end

  scope "/", PcdmApi do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/objects", PcdmApi do
    pipe_through :api

    get "/:id", ResourceController, :show
    get "/:id/relationships/members", ResourceController, :members
    post "/", ResourceController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", PcdmApi do
  #   pipe_through :api
  # end
end
