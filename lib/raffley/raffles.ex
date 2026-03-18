defmodule Raffley.Raffles do
  import Ecto.Query
  alias Raffley.Raffles.Raffle
  # alias Raffley.Charities.Charity
  alias Raffley.Repo

  def list_raffles, do: Repo.all(Raffle)

  def filter_raffles(filter) do
    Raffle
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> with_charity(filter["charity"])
    |> sort(filter["sort_by"])
    |> preload(:charity)
    |> Repo.all()
  end

  defp with_charity(query, slug) when slug in ["", nil], do: query

  defp with_charity(query, slug) do
    # from r in query,
    #   join: c in Charity,
    #   on: r.charity_id == c.id,
    #   where: c.slug == ^slug

    from r in query,
      join: c in assoc(r, :charity),
      where: c.slug == ^slug
  end

  defp with_status(query, status) when status in ~w(open closed upcoming),
    do: where(query, status: ^status)

  defp with_status(query, _), do: query

  defp search_by(query, q) when q in ["", nil], do: query

  defp search_by(query, q), do: where(query, [r], ilike(r.prize, ^"%#{[q]}%"))

  defp sort(query, "prize"), do: order_by(query, :prize)

  defp sort(query, "ticket_price_desc"), do: order_by(query, desc: :ticket_price)

  defp sort(query, "ticket_price_asc"), do: order_by(query, asc: :ticket_price)

  defp sort(query, "charity") do
    from r in query,
      join: c in assoc(r, :charity),
      order_by: c.name
  end

  defp sort(query, _), do: order_by(query, :id)

  def get_raffle!(id) do
    Raffle
    |> Repo.get!(id)
    |> Repo.preload(:charity)
  end

  def featured_raffles(raffle) do
    # Process.sleep(2000)

    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
