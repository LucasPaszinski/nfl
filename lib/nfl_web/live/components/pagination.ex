defmodule NflWeb.Live.Components.Pagination do
  @moduledoc """
  Pagination for table, create a pages bar, that allow to select the page that you want to see
  """
  use NflWeb, :live_component

  def pages_sizes do
    ~w(10 25 50 100 500 1000)
  end

  def render(assigns) do
    ~L"""
    <nav>
     <ul class="pagination horizontal">
       <li>
         <a
            href="#"
            phx-click="nav"
            phx-value-page="<%= if @page > 1 , do: @page - 1, else: @page %>"
          >
            <
          </a>
       </li>
    <%= for idx <- 1..@total_pages do %>
       <li>
        <a
          href="#"
          phx-click="nav"
          phx-value-page="<%= idx %>"
          class="<%= if @page == idx, do: "active" %>"
        >
          <%= idx %>
        </a>
       </li>
    <% end %>
       <li>
         <a
         href="#"
         phx-click="nav"
         phx-value-page="<%= if @page < @total_pages , do: @page - 1, else: @page %>"
         >
          >
        </a>
       </li>
     </ul>
     </nav>
    """
  end
end
