defmodule CandyMart.Orders do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias CandyMart.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias CandyMart.Orders.Order
  alias CandyMart.Orders.Customer

  @pagination [page_size: 15]
  @pagination_distance 5
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("")

  @doc """
  Paginate the list of orders using filtrex
  filters.

  ## Examples

      iex> list_orders(%{})
      %{orders: [%Order{}], ...}
  """
  @spec paginate_orders(map) :: {:ok, map} | {:error, any}
  def paginate_orders(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:orders), params["order"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_orders(filter, params) do
      entries =
        page.entries
        |> Enum.map(fn order ->
          customer = get_customer(order.customer_id)
          order |> Map.put(:customer_name, customer.name)
        end)

      {:ok,
       %{
         orders: entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_orders(filter, params) do
    Order
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  def get_orders_query() do
    from(order in Order,
      join: customer in Customer,
      on: customer.id == order.customer_id
      # select: %{order | customer: customer}
    )
  end

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(Order)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id)

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{source: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  defp filter_config(:orders) do
    defconfig do
    end
  end

  def generate_string(length \\ 5) do
    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end

  def create_customer_order(params) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:customer, fn _repo, _ ->
      customer_id = params["customer_id"]

      with %Customer{} = customer <- get_customer(customer_id) do
        {:ok, customer}
      else
        _ ->
          create_customer(%{id: params["customer_id"], name: generate_string()})
      end
    end)
    |> Ecto.Multi.run(:order, fn _repo, %{customer: _customer} ->
      create_order(params)
    end)
    |> Repo.transaction()
  end

  def add_order(%{"_json" => data}) when is_list(data) do
    data
    |> Enum.map(&add_order/1)
    |> Enum.reduce_while({:ok, []}, fn
      {:ok, result}, {_status, acc} ->
        {:cont, {:ok, acc ++ [result]}}

      _, {_status, acc} ->
        {:halt, {:error, acc}}
    end)
  end

  def add_order(data) do
    data
    |> Map.put("product_name", data["product"])
    |> Map.put("unit_cost", round(data["unit_cost"]))
    |> Map.put("total_cost", round(data["total_cost"]))
    |> create_order()
  end

  def parse_csv(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&String.split(&1, ","))
    |> Enum.to_list()
  end

  def import_csv(file_path) do
    [_header | rows] =
      file_path
      |> parse_csv()

    rows
    |> Stream.map(&order_changeset(&1))
    |> Stream.map(&create_multi_transaction/1)
    |> Task.async_stream(&Repo.transaction(&1), max_concurrency: 50, ordered: false)
    |> Enum.reduce_while(:ok, fn
      {:ok, {:ok, _result}}, _acc ->
        {:cont, :ok}

      _, _acc ->
        {:halt, :error}
    end)
  end

  def order_changeset(row) do
    header = [
      "product_name",
      "unit_cost",
      "total_cost",
      "quantity",
      "inserted_at",
      "customer_id"
    ]

    attrs =
      header
      |> Stream.zip(row)
      |> Map.new()

    %Order{}
    |> Order.changeset(attrs)
  end

  def create_multi_transaction(changeset) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:orders, changeset)
  end

  def get_order_statistics(range \\ "month") do
    get_orders(range) |> get_orders_data(range)
  end

  def get_orders("month") do
    from(order in Order,
      group_by: [fragment("date_part('month', ?)", order.inserted_at), fragment("month")],
      select: %{
        count: count(order.id),
        date: fragment("to_char(?, 'Month') as month", order.inserted_at)
      },
      order_by: fragment("date_part('month', ?)", order.inserted_at)
    )
    |> Repo.all()
  end

  def get_orders("year") do
    from(order in Order,
      group_by: [fragment("date_part('year', ?)", order.inserted_at)],
      select: %{
        count: count(order.id),
        date: fragment("date_part('year', ?)::int", order.inserted_at)
      },
      order_by: fragment("date_part('year', ?)", order.inserted_at)
    )
    |> Repo.all()
  end

  def get_orders(_), do: []

  def get_orders_data([], _), do: %{data: [], labels: [], title: ""}

  def get_orders_data(orders, range) do
    {data, years} =
      orders
      |> Enum.reduce({[], []}, fn order, {acc_data, acc_label} ->
        label = order.date |> to_string() |> String.trim()
        {acc_data ++ [order.count], acc_label ++ [label]}
      end)

    %{data: data, labels: years, title: String.capitalize(range)}
  end

  @doc """
  Returns the list of customers.

  ## Examples

      iex> list_customers()
      [%Customer{}, ...]

  """
  def list_customers do
    Repo.all(Customer)
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id), do: Repo.get!(Customer, id)

  def get_customer(id), do: Repo.get(Customer, id)

  @doc """
  Creates a customer.

  ## Examples

      iex> create_customer(%{field: value})
      {:ok, %Customer{}}

      iex> create_customer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{data: %Customer{}}

  """
  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end
end
