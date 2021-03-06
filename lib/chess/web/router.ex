defmodule Chess.Web.Router do
  use Chess.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Chess.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", Chess.Web do
    pipe_through :api

    resources "/games", GameController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :edit]
  end
end
