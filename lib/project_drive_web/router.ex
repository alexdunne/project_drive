defmodule ProjectDriveWeb.Router do
  @moduledoc """
  Router configuration
  """

  use ProjectDriveWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ProjectDriveWeb.Plugs.Context
  end

  scope "/api" do
    pipe_through(:api)

    scope "/auth" do
      post "/register", ProjectDriveWeb.AuthController, :register
      post "/login", ProjectDriveWeb.AuthController, :login
      post "/refresh", ProjectDriveWeb.AuthController, :refresh
    end

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: ProjectDriveWeb.Schema,
      socket: ProjectDriveWeb.UserSocket

    forward "/", Absinthe.Plug, schema: ProjectDriveWeb.Schema
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ProjectDriveWeb.Telemetry
    end
  end
end
