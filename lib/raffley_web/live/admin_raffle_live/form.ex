defmodule RaffleyWeb.AdminRaffleLive.Form do
  use RaffleyWeb, :live_view

  alias Raffley.Admin
  alias Raffley.Raffles.Raffle
  alias Raffley.Charities

  import RaffleyWeb.CustomComponents

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:charity_options, Charities.charity_names_and_ids())
      |> allow_upload(:image,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 1,
        max_file_size: 10_000_000
      )
      |> apply_action(socket.assigns.live_action, params)

    {:ok, socket}
  end

  defp apply_action(socket, :new, _params) do
    raffle = %Raffle{}
    changeset = Admin.change_raffle(raffle)

    socket
    |> assign(:page_title, "New Raffle")
    |> assign(:form, to_form(changeset))
    |> assign(:raffle, raffle)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    raffle = Admin.get_raffle!(id)
    changeset = Admin.change_raffle(raffle)

    socket
    |> assign(:page_title, "Edit Raffle")
    |> assign(:form, to_form(changeset))
    |> assign(:raffle, raffle)
  end

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>

    <.simple_form
      for={@form}
      id="raffle-form"
      phx-submit="save"
      phx-change="validate"
      phx-drop-target={@uploads.image.ref}
    >
      <.input field={@form[:prize]} label="Prize" />

      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur" />

      <.input field={@form[:ticket_price]} type="number" label="Ticket Price" />

      <.input
        field={@form[:status]}
        type="select"
        label="Status"
        prompt="Choose a status"
        options={[
          :upcoming,
          :open,
          :closed
        ]}
      />

      <.input
        field={@form[:charity_id]}
        type="select"
        label="Charities"
        prompt="Choose a charity"
        options={@charity_options}
      />

      <div class="space-y-4">
        
    <!-- Upload -->
        <.upload_dropzone upload={@uploads.image} />
        
    <!-- Existing image (edit mode) -->
        <.existing_image
          :if={@raffle.image_path && @uploads.image.entries == []}
          src={@raffle.image_path}
        />
        
    <!-- New upload preview -->
        <div class="flex gap-4 flex-wrap">
          <.upload_preview
            :for={entry <- @uploads.image.entries}
            entry={entry}
            upload={@uploads.image}
          />
        </div>
      </div>

      <:actions>
        <.button phx-disable-with="Saving...">
          Save
        </.button>
      </:actions>
    </.simple_form>
    <.back navigate={~p"/admin/raffles"}>Back</.back>
    """
  end

  def handle_event("validate", %{"raffle" => raffle_params}, socket) do
    changeset = Admin.change_raffle(socket.assigns.raffle, raffle_params)
    socket = assign(socket, :form, to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  # def handle_event("save", %{"raffle" => raffle_params}, socket) do
  #   save_raffle(socket, socket.assigns.live_action, raffle_params)
  # end

  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    uploads_dir = Application.app_dir(:raffley, "priv/static/uploads")
    File.mkdir_p!(uploads_dir)

    uploaded_files =
      consume_uploaded_entries(socket, :image, fn meta, entry ->
        dest = Path.join(uploads_dir, "#{entry.uuid}-#{entry.client_name}")

        File.cp!(meta.path, dest)

        {:ok, "/uploads/#{Path.basename(dest)}"}
      end)

    raffle_params =
      case uploaded_files do
        [path] -> Map.put(raffle_params, "image_path", path)
        [] -> raffle_params
      end

    save_raffle(socket, socket.assigns.live_action, raffle_params)
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  defp save_raffle(socket, :new, raffle_params) do
    case Admin.create_raffle(raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle Created Successfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end

  defp save_raffle(socket, :edit, raffle_params) do
    case Admin.update_raffle(socket.assigns.raffle, raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle Updated Successfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end
end
