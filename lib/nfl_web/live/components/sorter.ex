defmodule NflWeb.Live.Components.Sorter do
  @moduledoc """
  Sorting icon and events. Allow sorting (asc - desc - no-sort)
  """
  use NflWeb, :live_component

  def render(assigns) do
    ~L"""
    <%= if @sort == @row_sort and @ord == "desc" do %>
    <<%= @wrapper %> class="<%= @row_sort %>" phx-click="sort" phx-value-sort="<%= @row_sort %>" phx-value-ord="asc">
      <div class="sorter">
        <i class="gg-sort-az"></i>
      </div>
      </<%= @wrapper %>>
      <% else %>
      <%= if @sort == @row_sort and @ord == "asc" do %>
      <<%= @wrapper %> class="<%= @row_sort %>" phx-click="sort" phx-value-sort="" phx-value-ord="">
      <div class="sorter">
        <i class="gg-sort-za"></i>
      </div>
    </<%= @wrapper %>>
    <% else %>
    <<%= @wrapper %> class="<%= @row_sort %>" phx-click="sort" phx-value-sort="<%= @row_sort %>" phx-value-ord="desc">
      <div class="sorter">
        <i class="gg-arrows-exchange-v"></i>
      </div>
    </<%= @wrapper %>>
    <% end%>
    <% end%>
    """
  end
end
