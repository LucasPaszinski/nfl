defmodule NflWeb.Live.Components.PageSize do
  @moduledoc """
  Page size (number of rows per page) configuration to the table
  """
  use NflWeb, :live_component

  def pages_sizes do
    [10, 25, 50, 100, 500, 1000]
  end

  def render(assigns) do
    ~L"""
    <nav>
     <ul class="pagination horizontal">
      <%= for page_size <- pages_sizes() do %>
       <li>
          <a
            href="#"
            phx-click="row"
            phx-value-row="<%= page_size %>"
            class="hold <%= if @page_size == page_size, do: "active" %>"
          >
            <%= page_size %>
          </a>
       </li>
       <% end %>
     </ul>
    </nav>
    """
  end
end
