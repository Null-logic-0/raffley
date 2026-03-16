defmodule RaffleyWeb.RulesHTML do
  use RaffleyWeb, :html

  embed_templates "rules_html/*"

  def show(assigns) do
    ~H"""
    <div class="rules">
      <h1>Don't Forget...</h1>
      <p>
        {@rule.text}
      </p>
    </div>
    """
  end
end
