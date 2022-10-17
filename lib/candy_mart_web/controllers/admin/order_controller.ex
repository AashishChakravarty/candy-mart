defmodule CandyMartWeb.Admin.OrderController do
  use CandyMartWeb, :controller

  alias CandyMart.Orders
  alias CandyMart.Orders.Order

  
#  plug(:put_root_layout, {CandyMartWeb.LayoutView, "torch.html"})
  

  def index(conn, params) do
    case Orders.paginate_orders(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Orders. #{inspect(error)}")
        |> redirect(to: Routes.admin_order_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Orders.change_order(%Order{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"order" => order_params}) do
    case Orders.create_order(order_params) do
      {:ok, order} ->
        conn
        |> put_flash(:info, "Order created successfully.")
        |> redirect(to: Routes.admin_order_path(conn, :show, order))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    render(conn, "show.html", order: order)
  end

  def edit(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    changeset = Orders.change_order(order)
    render(conn, "edit.html", order: order, changeset: changeset)
  end

  def update(conn, %{"id" => id, "order" => order_params}) do
    order = Orders.get_order!(id)

    case Orders.update_order(order, order_params) do
      {:ok, order} ->
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: Routes.admin_order_path(conn, :show, order))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", order: order, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    {:ok, _order} = Orders.delete_order(order)

    conn
    |> put_flash(:info, "Order deleted successfully.")
    |> redirect(to: Routes.admin_order_path(conn, :index))
  end
end
