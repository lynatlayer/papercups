defmodule ChatApi.CustomersTest do
  use ChatApi.DataCase

  alias ChatApi.Customers
  alias ChatApi.Accounts

  describe "customers" do
    alias ChatApi.Customers.Customer

    @valid_attrs %{
      first_seen: ~D[2020-01-01],
      last_seen: ~D[2020-01-01]
    }
    @update_attrs %{
      first_seen: ~D[2020-01-01],
      last_seen: ~D[2020-01-02]
    }
    @invalid_attrs %{
      first_seen: 3
    }

    def add_account_id(attrs) do
      {:ok, account} = Accounts.create_account(%{company_name: "Taro"})
      attr = Enum.into(attrs, %{account_id: account.id})
      attr
    end

    def customer_fixture(attrs \\ %{}) do
      {:ok, customer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> add_account_id()
        |> Customers.create_customer()

      customer
    end

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Customers.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Customers.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      assert {:ok,
              %Customer{
                first_seen: ~D[2020-01-01],
                last_seen: ~D[2020-01-01]
              } = customer} = Customers.create_customer(add_account_id(@valid_attrs))
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{} = customer} = Customers.update_customer(customer, @update_attrs)
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_customer(customer, @invalid_attrs)
      assert customer == Customers.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Customers.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Customers.change_customer(customer)
    end
  end
end
