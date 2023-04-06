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

    Phoenix.LiveView server side life cycles
  -------------------------------------------

  Phoenix.LiveView defines 5 server side life cycles:
    1. :mount
    2. :handle_event
    3. :handle_params
    4. :handle_info
    5. :after_render

  **Note**

  Phoenix.LiveView runs any hooks attached before all the life cycles except for the hooks attached to
  the `:after_render` which run after rendering has taken place.

    Attaching a hooks to any of the life cycle
  ----------------------------------------------

  - With the exception of of the `:mount` lifecycle which we attach a hook using the `on_mount/1` macro,
    hooks are attached using `attach_hook/4` function that takes the following arguments:

    a. Socket (Phoenix.LiveView.Socket.t())
    b. hook_name (atom())
    c. lifecycle state ( :handle_params, :handle_event, :after_event, :handle_info)
    d. function ( the arity of the function depends on the stage)


      Examples
    -----------
    a. :handle_event
        attach_hook(socket, :some_name, :handle_event, fn event, params, socket -> {:cont, socket} end)

    b. :handle_params
        attach_hook(socket, :some_name, :handle_params, fn params, uri, socket -> {:cont, socket} end)

    c. :handle_info
        attach_hook(socket, :some_name, :handle_info, fn event, socket -> {:cont, socket} end)

    d. :after_render
        attach_hook(socket, :some_name, :after_render, fn socket -> {:cont, socket} end)


  When defining a hook through attaching a hook or in the mount/4 function, Phoenix.LiveView expects
  the return values to either be:

    a. {:cont, socket} -> Indicates to Phoenix.LiveView that after invoking the hook, it should
        proceed to invoke the life cycle callback as normal

    b. {:halt, socket} -> Indicates to Phoenix.LiveView that after invoking the hook, it should
        not proceed to invoking the life cycle callback as normal.

        => Remember that when redirecting the user, it's important to halt the normal reduction of
          the socket.

        **Note**

        => Whenever you attach a hook that stops the normal reduction of the socket, it's important
          to ensure that you detach the hook later by returning `{:halt, detach_hook(socket, :hook_name)}`
          or providing a catch all hook if the hooks matches for specific items in the arguements


  """
  import Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  require Logger

  def on_mount(_, params, session, %Socket{} = socket) do
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
