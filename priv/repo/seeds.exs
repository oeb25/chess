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
