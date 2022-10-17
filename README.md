# Candy Mart

Candy Mart is a test application that represents a small backend system to track and display sales for a bulk candy supplier.

Your goal is to complete as many of the tasks as you can. Feel free to fix any bugs or cleanup anything you think needs it.

# Setup and getting started

This app requires a recent version of elixir and postgres.

To start the server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Provided files and pre-configured libraries

### money
all money is stored to the database as integers; to make dealing with this easier, the money library has been added

### torch
a basic admin framework with a simple page setup to add statistics

### pow
the pow authentication framework has been pre-installed and a user is created via the seed data

### priv/repo/seeds.exs
5ome user seed data currently exists to provide a login to the admin panel; this will automatically be imported when you run `mix ecto.setup`, but you can also manually run it via  `mix run priv/repo/seeds.exs`

### priv/data/candy_sales.csv
provides a bulk import of sales data going back a year

### tools/post_new_sale.ex
a simple tool to generate POST requests with sample data to /api/sales; can be run with `mix run tools/post_new_sale.exs`


# Tasks and Ideas

  - [ ] Create a csv importer in the admin panel that allows the user to upload priv/data/candy_sales.csv
  - [ ] Create an api endpoint to process incoming sales events from api integrations (should support json and urlencoded form data; example requests can be made via `mix run priv/repo/seeds.exs`)
  - [ ] Make a little view to display the current sales statistics (sales by month, year, all time, etc)
  - [ ] Normalize products and customers out of orders
  - [ ] Add the ability to process multiple orders at a time through the web api
  - [ ] Lock down the api endpoint so random users can't access it
  - [ ] Fix any issues or make any upgrades you think should be done
  - [ ] Anything else you think of adding or changing!
