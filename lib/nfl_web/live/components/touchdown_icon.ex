defmodule NflWeb.Live.Components.TouchdownIcon do
  use NflWeb, :live_component

  def render(assigns) do
    ~L"""
      <%= if @is_touchdown do %>
      <button phx-click="touchdown" class="touchdown-button"><%= @longest_rush %> T</button>
      <% else %>
      <span><%= @longest_rush %></span>
      <% end %>
    """
  end
end
