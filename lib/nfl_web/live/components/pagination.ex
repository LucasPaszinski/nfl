defmodule NflWeb.Live.Components.Pagination do
  use NflWeb, :live_component

  def render(assigns) do
    ~L"""
    <nav>
     <ul class="pagination horizontal">
       <li>
         <a class="<%= if @page_number <= 1, do: "active" %>" href="#" phx-click="nav" phx-value-page="<%= @page_number - 1 %>">Previous</a>
       </li>
    <%= for idx <-  Enum.to_list(1..@total_pages) do %>
       <li>
       <a class="<%= if @page_number == idx, do: "active" %>" href="#" phx-click="nav" phx-value-page="<%= idx %>"><%= idx %></a>
       </li>
    <% end %>
       <li>
         <a class="<%= if @page_number >= @total_pages, do: "active" %>" href="#" phx-click="nav" phx-value-page="<%= @page_number + 1 %>">Next</a>
       </li>
     </ul>
     </nav>

     <nav>
     <ul class="pagination horizontal">
       <li>
         <a class="<%= if @page_size <= 1, do: "active" %>" href="#" phx-click="page-size" phx-value-page-size="10">10</a>
       </li>
       <li>
         <a class="<%= if @page_size <= 1, do: "active" %>" href="#" phx-click="page-size" phx-value-page-size="25">25</a>
       </li>
       <li>
         <a class="<%= if @page_size <= 1, do: "active" %>" href="#" phx-click="page-size" phx-value-page-size="50">50</a>
       </li>
       <li>
         <a class="<%= if @page_size <= 1, do: "active" %>" href="#" phx-click="page-size" phx-value-page-size="100">100</a>
       </li>
       <li>
         <a class="<%= if @page_size <= 1, do: "active" %>" href="#" phx-click="page-size" phx-value-page-size="500">500</a>
       </li>
       <li>
         <a class="<%= if @page_size <= 1, do: "active" %>" href="#" phx-click="page-size" phx-value-page-size="1000">1000</a>
       </li>
     </ul>
     </nav>

    """
  end
end
