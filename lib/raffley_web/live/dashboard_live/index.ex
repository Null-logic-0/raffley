defmodule RaffleyWeb.DashboardLive do
  use RaffleyWeb, :live_view
  alias Raffley.Admin

  def mount(_params, _session, socket) do
    data = Admin.ticket_tallies()

    {:ok, assign(socket, :data, data)}
  end

  def render(assigns) do
    ~H"""
    <.header>
      Dashboard
      <:actions>
        <.link href={~p"/export/report"} class="button">
          <.icon name="hero-arrow-down-tray" class="h-4 w-4" /> Export
        </.link>
      </:actions>
    </.header>
    <.table id="report" rows={@data}>
      <:col :let={item} label="Prize">
        {item[:prize]}
      </:col>

      <:col :let={item} label="Charity">
        {item[:charity]}
      </:col>

      <:col :let={item} label="Ticket Count">
        {item[:ticket_count]}
      </:col>

      <:col :let={item} label="Ticket Total">
        ${item[:ticket_total]}
      </:col>
    </.table>
    """
  end
end
