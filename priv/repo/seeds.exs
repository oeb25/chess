# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Chess.Repo.insert!(%Chess.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Chess.Auth
alias Chess.Games



# Users

{:ok, jenner} = Auth.create_user(%{
	name: "jenner",
  email: "ibidims@hotmail.com",
  password: "123pass"
})

{:ok, oliver} = Auth.create_user(%{
  name: "oliver",
  email: "oliverboving@gmail.com",
  password: "123pass"
})

{:ok, oscar} = Auth.create_user(%{
  name: "oscar",
  email: "oespringbord@gmail.com",
  password: "123pass"
})



# Games
{:ok, rule_set} = %{
  type: :standard,
  time_limit: :infinite,
} |> Games.RuleSet.cast


{:ok, game1} = Games.create_game(%{
  white: %{
    type: :anonymus,
    user_id: "retrstrdiuoaupyoift",
  },
  black: %{
    type: :anonymus,
    user_id: "sadljhlgoilruahsdu6",
  },
  actions: [
    %{type: :move, from: :A2, to: :A3}
  ],
  rule_set: rule_set,
})

