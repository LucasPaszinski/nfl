defmodule NflWeb.Live.Components.Sorter do
  use NflWeb, :live_component

  def render(assigns) do
    ~L"""
    <%= if @sort_by == @row_sort and @order_by == "desc" do %>
    <%= live_patch to: Routes.rushes_path(@socket, :index,%{sort_by: @row_sort, order_by: "asc", filter_by: "player_name", filter_value: @filter_value}) do %>
      <div class="triangle-down"></div>
    <% end %>
    <% else %>
    <%= live_patch to: Routes.rushes_path(@socket, :index,%{sort_by: @row_sort, order_by: "desc", filter_by: "player_name", filter_value: @filter_value})  do %>
       <div class="triangle-up"></div>
    <% end %>
    <% end %>
    """
  end
end
