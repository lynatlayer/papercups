defmodule ChatApiWeb.AccountController do
  use ChatApiWeb, :controller

  alias ChatApi.Accounts
  alias ChatApi.Accounts.Account

  action_fallback ChatApiWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, "index.json", accounts: accounts)
  end

  @spec create(any, map) :: any
  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.account_path(conn, :me))
      |> render("create.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, "show.json", account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, "show.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end

  def me(conn, _params) do
    case conn.assigns.current_user do
      %{account_id: account_id} ->
        account = Accounts.get_account!(account_id)

        render(conn, "show.json", account: account)

      nil ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid token"}})
    end
  end
end
