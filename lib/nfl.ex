defmodule Nfl do
  @moduledoc """
  Nfl keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defdelegate rushes, to: Nfl.Rushes.Index
end
