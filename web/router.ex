defmodule Chess.Router do
  use Chess.Web, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", Chess do
  #   pipe_through :browser
  #   # pipe_through :authorize

  #   get "/login", AuthController, :login
  #   post "/login", AuthController, :callback
  #   get "/logout", AuthController, :logout
  # end

  scope "/auth", Chess do
    pipe_through [:browser, :browser_auth]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/", Chess do
    pipe_through [:browser, :browser_auth]

    resources "/gameUser", GameUserController
    resources "/games", GameController
    get "/", PageController, :index
  end

  scope "/users", Chess do
    pipe_through [:browser, :browser_auth]

    resources "/", UserController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Chess do
  #   pipe_through :api
  # end
end
