defmodule NflWeb.Live.Components.Sorter do
  use NflWeb, :live_component

  def render(assigns) do
    ~L"""
    <%= if @sort == @row_sort and @ord == "desc" do %>
    <div class="sorter triangle-up" phx-click="sort" phx-value-sort="<%= @row_sort %>" phx-value-ord="asc"></div>
    <% else %>
    <%= if @sort == @row_sort and @ord == "asc" do %>
    <div class="sorter triangle-down" phx-click="sort" phx-value-sort="" phx-value-ord=""></div>
    <% else %>
    <div class="sorter square" phx-click="sort" phx-value-sort="<%= @row_sort %>" phx-value-ord="desc"></div>
    <% end%>
    <% end%>
    """
  end
end
