defmodule Raffley.TicketsFixtures do
  alias Raffley.Raffles.Raffle
  alias Raffley.Accounts.User

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Raffley.Tickets` context.
  """

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    # or use a fixture for raffle
    raffle = %Raffle{id: 1}
    # or use a fixture for user
    user = %User{id: 1}

    {:ok, ticket} =
      Raffley.Tickets.create_ticket(
        raffle,
        user,
        attrs
        |> Enum.into(%{
          comment: "some comment",
          price: 42
        })
      )

    ticket
  end
end
