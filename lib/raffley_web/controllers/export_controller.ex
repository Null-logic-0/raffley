defmodule RaffleyWeb.ExportController do
  use RaffleyWeb, :controller

  def report(conn, _params) do
    data =
      Raffley.Admin.ticket_tallies()
      |> CSV.encode(headers: [:prize, :charity, :ticket_count, :ticket_total])
      |> Enum.to_list()

    conn
    # |> put_resp_content_type("text/csv")
    # |> put_resp_header("content-disposition", "attachment; filename=report.csv")
    # |> send_resp(200, data)
    |> send_download({:binary, data}, filename: "report.csv")
  end
end
