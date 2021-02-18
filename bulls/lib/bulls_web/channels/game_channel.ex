defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  alias Bulls.Game

  @impl true
  def join("game:" <> _id, payload, socket) do
    IO.puts("JOIN")
    try do
      if authorized?(payload) do
        game = Game.new
        socket = assign(socket, :game, game)
        view = Game.view(game)
        {:ok, view, socket}
      else
        {:error, %{reason: "unauthorized"}}
      end
    rescue
      err in RuntimeError -> Logger.error(Exception.format(:error, err, __STACKTRACE__))
      {:error, %{reason: "runtime error"}}
    end
  end

  @impl true
  def handle_in("message", %{"guess" => guess}, socket0) do
    IO.puts("MSG")
    game0 = socket0.assigns[:game]
    game1 = Game.guess(game0, guess)
    socket1 = assign(socket0, :game, game1)
    view = Game.view(game1)
    {:reply, {:ok, view}, socket1}
  end

  @impl true
  def handle_in("reset", _, socket) do
    IO.puts("RESET")
    game = Game.new
    socket = assign(socket, :game, game)
    view = Game.view(game)
    {:reply, {:ok, view}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end