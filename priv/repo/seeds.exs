# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CandyMart.Repo.insert!(%CandyMart.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CandyMart.Users.User
alias CandyMart.Repo

%User{}
|> User.changeset(%{
  email: "owner@candymart.com",
  password: "candyland",
  password_confirmation: "candyland"
})
|> Repo.insert!()
