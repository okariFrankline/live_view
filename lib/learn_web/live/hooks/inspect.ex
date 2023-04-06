defmodule LearnWeb.Live.Hooks.Inspect do
  @moduledoc """
  This module defines a simple mount hook that will be used to inspect the socket, session and params
  passed on mount

  How does it work?
  -------------------

  In order for a mount hook to work, it needs to be defined inside a live view using the macro `on_mount/1`

  ```elixir
  defmodule ThermoLive.Index do

    use Phoenix.LiveView

    on_mount ExploreWeb.Hooks.Inspect

  end
  ```

  Once the on_mount Hook callback has been defined, LiveView will ensure that the hooks are invoked in the order
  that they were added to the live view module.

  The invocation will happen both in disconnected and connected states during the live view mounting process
  """
  import Phoenix.LiveView

  alias Phoenix.LiveView.Socket

  require Logger

  @spec on_mount(type :: atom, params :: map, session :: map, socket) ::
          {:cont, socket} | {:halt, socket}
        when socket: Socket.t()
  def on_mount(_, params, session, socket) do
    {:cont, before_mount(socket, params, session)}
  end

  defp before_mount(socket, params, session) do
    socket
    |> log_before_mount(params, session)
    |> attach_inspect_hooks()
  end

  defp log_before_mount(socket, params, session) do
    Logger.info(
      """
      ----------------------------------------- BEFORE MOUNT START ----------------------------

                  Session: #{inspect(session)}
                  Params: #{inspect(params)}
                  Socket: #{inspect(socket)}

      ------------------------------------------- BEFORE MOUNT END ----------------------------

      """,
      ansi_color: :blue
    )

    socket
  end

  defp attach_inspect_hooks(socket) do
    # we are going to attach a hook that will be used to log the params and and the event
    # triggered by the client
    socket
    |> attach_hook(:inspect_event, :handle_event, fn
      event, params, socket ->
        Logger.info(
          """
          ----------------------------------------- HANDLE EVENT START (#{inspect(event)}) ----------------------------

                  Event: #{inspect(event)}
                  Params: #{inspect(params)}
                  Socket: #{inspect(socket)}

          ------------------------------------------- HANDLE EVENT END (#{inspect(event)}) ----------------------------
          """,
          ansi_color: :green
        )

        {:cont, socket}
    end)
    |> attach_hook(:inspect_handle_params, :handle_params, fn
      params, uri, socket ->
        Logger.warning("""
        ----------------------------------------- HANDLE PARAMS START (#{inspect(uri)}) ----------------------------

                URI: #{inspect(uri)}
                Params: #{inspect(params)}
                Socket: #{inspect(socket)}

        ------------------------------------------- HANDLE PARAMS END (#{inspect(uri)}) ----------------------------
        """)

        {:cont, socket}
    end)
  end
end
