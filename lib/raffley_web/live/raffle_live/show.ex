defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view

  import RaffleyWeb.CustomComponents
  alias Raffley.Raffles
  alias Raffley.Tickets
  alias Raffley.Tickets.Ticket

  on_mount {RaffleyWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    _changeset = Tickets.change_ticket(%Ticket{})
    socket = assign(socket, :form, to_form(%{}))
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    raffle = Raffles.get_raffle!(id)

    socket =
      socket
      |> assign(:raffle, raffle)
      |> assign(:page_title, raffle.prize)
      |> assign_async(:featured_raffles, fn ->
        {:ok, %{featured_raffles: Raffles.featured_raffles(raffle)}}
        # {:error, "Out to lunch!"}
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-show">
      <div class="raffle">
        <img src={@raffle.image_path} src={@raffle.prize} />
        <section>
          <.badge status={@raffle.status} />
          <header>
            <div>
              <h2>{@raffle.prize}</h2>
              <h3>{@raffle.charity.name}</h3>
            </div>
            <div class="price">
              ${@raffle.ticket_price} / ticket
            </div>
          </header>
          <div class="description">
            {@raffle.description}
          </div>
        </section>
      </div>
      <div class="activity">
        <div class="left">
          <div :if={@raffle.status == :open}>
            <%= if @current_user do %>
              <.form for={@form} id="ticket-form">
                <.input field={@form[:comment]} placeholder="Comment..." autofocus={true} />
                <.button>
                  Get A Ticket
                </.button>
              </.form>
            <% else %>
              <.link href={~p"/users/log-in"} class="button">
                Log In To Get A Ticket
              </.link>
            <% end %>
          </div>
        </div>
        <div class="right">
          <.featured_raffles raffles={@featured_raffles} />
        </div>
      </div>
    </div>
    """
  end

  def featured_raffles(assigns) do
    ~H"""
    <h4>Featured Raffles</h4>
    <.async_result :let={result} assign={@raffles}>
      <:loading>
        <div class="loading">
          <div class="spinner"></div>
        </div>
      </:loading>
      <:failed :let={{:error, reason}}>
        <div class="failed">
          Yikes {reason}
        </div>
      </:failed>

      <ul class="raffles">
        <li :for={raffle <- result}>
          <.link navigate={~p"/raffles/#{raffle}"}>
            <img src={raffle.image_path} alt={raffle.prize} />
            {raffle.prize}
          </.link>
        </li>
      </ul>
    </.async_result>
    """
  end
end
