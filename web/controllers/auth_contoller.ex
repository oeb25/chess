defmodule Chess.AuthController do
	use Chess.Web, :controller

	import Joken
	import Chess.Router.Helpers

	def login(%{ assigns: %{ :user => user } } = conn, _params) when user != nil do
		conn
		|> put_flash(:info, "Du er allerade logget ind")
		|> redirect(to: Chess.UserController.index_route(conn, user))
	end
	def login(conn, _params) do
		render conn, :login,
			callback_url: auth_path(conn, :callback)
	end

	def signup(conn, _params) do
		render conn, :login
	end

	def logout(conn, _params) do
		conn
		|> put_resp_cookie("user-jwt", "")
		|> redirect(to: auth_path(conn, :login))
	end

	def secret do
		"secret secret secret"
	end

	def callback(conn, %{"email" => email, "password" => password}) do
		case Repo.get_by(Chess.User, email: email) do
			nil ->
				conn
				|> put_flash(:error, "En klient med dette klientnummer blev ikke fundet")
				|> redirect(to: auth_path(conn, :login))

			{:err, _} ->
				conn
				|> put_flash(:error, "En klient med dette klientnummer blev ikke fundet")
				|> redirect(to: auth_path(conn, :login))

			user ->
				case UserController.login(user, password) do
					{:ok, user} ->
						token = %{email: email}
						|> token
						|> with_signer(hs256(secret()))
						|> sign
						|> get_compact

						conn = conn
						|> put_flash(:info, "Login success!")
						|> put_resp_cookie("user-jwt", token)
						
						case UserController.type_of(user) do
							# :client ->
							# 	conn
							# 	|> redirect(to: client_path(conn, :index))
							# :seller ->
							# 	conn
							# 	|> redirect(to: seller_path(conn, :index))
							:admin ->
								conn
								|> redirect(to: auth_path(conn, :index)) # TODO
							_ ->
								conn
								|> redirect(to: auth_path(conn, :login))
						end
					{:err, _} ->
						conn
						|> put_flash(:error, "Forket password!")
						|> redirect(to: auth_path(conn, :login))
				end
		end
	end
	def callback(conn, _params), do: conn |> redirect(to: auth_path(conn, :login))

  def get_token(%{cookies: %{ "user-jwt" => token_str }} = conn, _) do
    token =
      token_str
      |> token
      |> with_signer(hs256(secret()))
      |> verify

    conn
    |> assign(:token, token)
  end
  def get_token(conn, _), do: assign conn, :token, nil
  
  def get_user_from_token(%{assigns: %{token: %{claims: %{ "email" => email }}}} = conn, _) do
    conn
    |> assign(:user, Repo.get_by(Chess.User, email: email))
  end

  def get_user_from_token(conn, _) do
    conn
    |> assign(:user, nil)
  end

	def only_allow_if_logged_in(conn, _) do
		case conn.assigns[:user] do
		  nil ->
				conn
				|> put_flash(:error, "Du skal logge ind for at kunne se disse oplysninger")
				|> redirect(to: auth_path(conn, :login))
				|> halt
		  _ ->
				conn
		end
	end
end