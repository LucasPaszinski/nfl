defmodule Nfl.Cache do
  @moduledoc """
  A generic Cache.
  """
  use GenServer

  @is_test_env if Mix.env() == :test, do: true, else: false

  @spec create_key(String.t()) :: String.t()
  def create_key(text_id) do
    :md5
    |> :crypto.hash(text_id)
    |> Base.encode16()
  end

  def write(name \\ __MODULE__, key, value) do
    if not @is_test_env do
      true = :ets.insert(table_name(name), {key, value})
    end

    value
  end

  def read(name \\ __MODULE__, key) do
    {:ok, :ets.lookup_element(table_name(name), key, 2)}
  rescue
    ArgumentError -> {:error, "key no longer exists!"}
  end

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: table_name(opts))
  end

  defp new_table(name) do
    name
    |> table_name()
    |> :ets.new([:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
  end

  defp table_name(name: name) do
    :"#{name}.Cache"
  end

  defp table_name(name) do
    :"#{name}.Cache"
  end

  @clear_interval :timer.minutes(2)

  def init(opts) do
    state = %{
      interval: opts[:clear_interval] || @clear_interval,
      timer: nil,
      table: new_table(opts[:name])
    }

    {:ok, schedule_clear(state)}
  end

  def handle_info(:clear, state) do
    :ets.delete_all_objects(state.table)

    {:noreply, schedule_clear(state)}
  end

  defp schedule_clear(state) do
    %{state | timer: Process.send_after(self(), :clear, state.interval)}
  end
end
