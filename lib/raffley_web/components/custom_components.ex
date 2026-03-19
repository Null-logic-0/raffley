defmodule RaffleyWeb.CustomComponents do
  use RaffleyWeb, :html

  attr :status, :atom, values: [:upcoming, :open, :close], default: :upcoming
  attr :class, :string, default: nil

  def badge(assigns) do
    ~H"""
    <div class={[
      "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
      @status == :open && "text-green-600 border-green-600",
      @status == :upcoming && "text-amber-600 border-amber-600",
      @status == :closed && "text-red-600 border-red-600",
      @class
    ]}>
      {@status}
    </div>
    """
  end

  slot :inner_block, required: true
  slot :details

  def banner(assigns) do
    assigns = assign(assigns, :emoji, ~w(🤩 🥳 😎) |> Enum.random())

    ~H"""
    <div class="banner">
      <h1>
        {render_slot(@inner_block)}
      </h1>
      <div :for={details <- @details} class="details">
        {render_slot(details, @emoji)}
      </div>
    </div>
    """
  end

  def upload_dropzone(assigns) do
    ~H"""
    <label
      class="border-2 border-dashed rounded-xl p-6 text-center cursor-pointer block hover:border-zinc-400 transition"
      phx-drop-target={@upload.ref}
    >
      <.live_file_input upload={@upload} class="hidden" />

      <div class="text-zinc-600">
        <p class="font-medium">Click to upload</p>
        <p class="text-sm">or drag and drop</p>
      </div>

      <p class="text-xs text-zinc-400 mt-2">
        Max {trunc(@upload.max_file_size / 1_000_000)} MB
      </p>
    </label>
    """
  end

  def upload_preview(assigns) do
    ~H"""
    <div class="relative w-40">
      <.live_img_preview entry={@entry} class="rounded-xl shadow" />
      
    <!-- progress overlay -->
      <div class="absolute bottom-0 left-0 right-0 bg-black/60 text-white text-xs p-1 rounded-b-xl">
        {@entry.progress}%
        <div class="h-1 bg-white/30 mt-1">
          <div class="h-1 bg-white transition-all" style={"width: #{@entry.progress}%"}></div>
        </div>
      </div>
      
    <!-- cancel button -->
      <button
        type="button"
        phx-click="cancel-upload"
        phx-value-ref={@entry.ref}
        class="absolute top-1 right-1 bg-black/70 text-white rounded-full px-2"
      >
        ✕
      </button>
      
    <!-- errors -->
      <p :for={err <- upload_errors(@upload, @entry)} class="text-red-500 text-xs mt-1">
        {Phoenix.Naming.humanize(err)}
      </p>
    </div>
    """
  end

  def existing_image(assigns) do
    ~H"""
    <div class="relative w-40">
      <img src={@src} class="rounded-xl shadow" />

      <div class="absolute bottom-0 left-0 right-0 bg-black/50 text-white text-xs p-1 rounded-b-xl text-center">
        Current image
      </div>
    </div>
    """
  end
end
