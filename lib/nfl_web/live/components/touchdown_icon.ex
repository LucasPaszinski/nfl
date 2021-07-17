defmodule NflWeb.Live.Components.TouchdownIcon do
  use NflWeb, :live_component

  def render(assigns) do
    ~L"""
    <%= if @is_touchdown do %>
      <span class="dot">
        T
      </span>
     <% end %>
    """
  end
end
