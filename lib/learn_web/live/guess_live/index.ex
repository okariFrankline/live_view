defmodule LearnWeb.GuessLive.Index do
  @moduledoc """
  This is a simple live view that creates a guessing game allowing a user
  to guess a number between 1 and 9

  If the number guessed is the same as the one stored, the user earns a single
  point and if not, they do not earn a point

  In order to make it more interesting, we are going to include hints based on whether
  the answer chosen is lower or higher than the number to be guessed

  We will also only allow each user only three chances to guess the correct number. If
  after 3 chances the user hasn't gotten it right, we display a modal informing them that
  they have lost and also display the total points earned

  If they have gotten it right, we display another modal letting them know that they got it
  correct, display the current points and asking whether they want to play again

  Objectives
  ----------

  By the end of this example, we should be able to:

    a. Correctly create a live view from scratch and display an initial setup and understand the mounting
      process for each live view

    b. Correctly handle events sent from user interactions with a live view application ( the main goal here
      is to understand how CRC is being used when working with live view)

    c. Using of live actions to control different states of a single live view (This will include the difference
      between live patching and live redirects )
  """

  use LearnWeb, :live_view

  import LearnWeb.GuessLive.GuessHtml

  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  alias Learn.Games
  alias Learn.Games.Guess

  alias LearnWeb.Live.Hooks.Inspect

  on_mount Inspect

  @doc """
  Mounts the live view

    How it works
  ---------------

  Whenever a user visits any router that is being served by a live view, Phoenix.LivView will first
  call this callback ( it is the responsibility of the this callback to prepare the socket for initial
  render)

  One thing to keep in mind is that this callback is invoked twice ( with the exception of navigation within a
  single live session):

    1. In the first invocation, it is called in a disconnected state ( here the live view is yet to start)

      => It's during this state that the first 'meaningful' page is rendered ( Basically, the user can
        see the page but cannot yet interact with it )

    2. In the second state, it's called in the connected state ( here the live view)

      => During this stage, the live view is started and the process is now ready to react to any
        interactions within the application.

      => It is in this connected state that doing things like setting up subscriptions is done

    Rendering of a page
  ----------------------

  In order for a page to render, Phoenix.LiveView invokes two callbacks that are expected to be
  implemented by our live views

    a. mount/3
    b. render/1

  While the mount/3 callback is always implemented, the render/1 function can be skipped as long as within the
  same folder structure we have a file heex file with the same name as the live view module.

  It is this file that Phoenix.LiveView will use to render the html


   on_mount Life cycle
  ---------------------

  One of the things introduced in Phoenix LiveView is the on_mount/1 macro that allows use to tap
  into the different lifecyles of reending a live view ( it's important to keep in mind that this
  is not the FE lifecycles but strictly the server part of the rendering process)

  The Phoenix.LiveView server life cycles are:

    1. :mount ( runs just before mount )
    2. :handle_event ( runs just beforehandling event )
    3. :after_render ( runs immediately after rendering )
    4. :handle_info ( runs immediately before handle_info is invoked)
    5. :handle_params ( runs immediately before handle_params is invoked)

  """
  @impl LiveView
  def mount(_params, _session, %Socket{} = socket) do
    {:ok, prepare_socket(socket), temporary_assigns: [form: nil]}
  end

  @doc """
  Callback responsible for handling params when doing and patch

  One of the things that makes Phoenix.LiveView cool is the ability to have multiple
  features implemented within the same live view.

  This is made possible by the fact that the live view can have multiple states at the
  same time, hence, making it easy to display and/or implement the multiple features.

  The way that phoenix liveview makes this possible is throught the user of live navigation
  using the `patch` option.

    How does this work
  ----------------------

  Phoenix.LiveView allows you to navigate to the same live view that is currently mounted using:
    a. push_patch/2
    b. link/1 function component with the assigns `:patch` provided (<.link patch={~p"/path"}> Path </.link>)

  Whenever any of this is encountered, Phoenix.LiveView will invoke the callback `handle_params/3` which is
  expected to reduce the socket state correctly in order to display the new state of the live view

  It is in this callback, for example, that it is expected to make changes to the socket ( i.e fetch a resource
  from the db, alter some assigns etc).

  After the invocation of this callback, Phoenix.LiveView will rerender the page to display the new feature

  **Note**

  When doing a patch, Phoenix.LiveView does not shutdown the currently mounted live view but instead reuses it.
  """
  @impl LiveView
  def handle_params(_params, _uri, %Socket{} = socket) do
    {:noreply, socket}
  end

  @doc """
  Handles event sent to the server as a result of user interactions

    How it works
  --------------

  Whenever a user interacts with our application e.g clicks, form submission etc, Phoenix.LiveView will
  emit an event which it expects the live view to handle.

  This event is handled in this callback and it receives three args

    1. Event name as string
    2. The params attached to the event
    3. The live view socket

  It is within this callback that Phoenix.LiveView expects the handling of the event and then maybe
  updating of the socket.

  If the socket assigns is updated, Phoenix.LiveView will them rerender only those bits that have changes
  within the assigns ( this ability to only render what has changed and not the entire page is one of those
  things that make Phoenix.LiveView cool)

  In our case, we just validate the number entered and return the feedback immediately. However, you can imagine
  doing a number of things here ( saving to db, making an http call etc)
  """
  @impl LiveView
  def handle_event("validate", %{"guess" => guess_params}, %Socket{} = socket) do
    {:noreply, handle_validate(socket, guess_params)}
  end

  def handle_event("check_guess", %{"guess" => guess_params}, %Socket{} = socket) do
    {:noreply, handle_check_guess(socket, guess_params)}
  end

  def handle_event("new_game", %{"reason" => reason, "dom_id" => dom_id}, %Socket{} = socket) do
    {:noreply, handle_new_game(socket, dom_id, reason)}
  end

  # adds the required assigns to the socket
  defp prepare_socket(%Socket{} = socket) do
    socket
    |> add_guess()
    |> add_actual_number()
    |> add_changeset_form()
    |> add_message_and_score_and_trials()
  end

  defp add_guess(socket), do: assign(socket, :guess, %Guess{})

  defp add_message_and_score_and_trials(socket),
    do: assign(socket, message: "", score: 0, trials: 3, guessed: 0)

  defp add_actual_number(socket) do
    1..9
    |> Enum.random()
    |> then(&assign(socket, :actual_number, &1))
  end

  defp add_changeset_form(%Socket{assigns: %{guess: guess}} = socket) do
    guess
    |> add_guess_form()
    |> then(&assign(socket, :form, &1))
  end

  defp add_guess_form(%Guess{} = guess) do
    guess
    |> Games.change_guess(%{})
    |> form_from_changeset()
  end

  defp form_from_changeset(%Ecto.Changeset{} = changeset), do: to_form(changeset, as: "guess")

  # validate the guess
  defp handle_validate(%Socket{assigns: %{guess: guess}} = socket, guess_params) do
    guess
    |> validate(guess_params)
    |> form_from_changeset()
    |> then(&assign(socket, :form, &1))
  end

  defp validate(%Guess{} = guess, guess_params) do
    # In order for live view to be able to display the errors within a form
    # it makes use of the `:action` field in the changeset.
    # If there's an action field, then it displays the error messages and if not
    # it does not display them ( hence we need to explicitly add the action here).
    # This is the reason why there are no errors being shown when we initially display
    # the form
    guess
    |> Games.change_guess(guess_params)
    |> Map.put(:action, :validate)
  end

  # check the guess
  defp handle_check_guess(
         %Socket{assigns: %{actual_number: number, guess: guess}} = socket,
         guess_params
       ) do
    case Games.check_guess(guess, guess_params, number) do
      {:ok, guess} -> update_from_guess(socket, guess)
      {:error, changeset} -> add_guess_error(socket, changeset)
    end
  end

  defp add_guess_error(%Socket{} = socket, %Ecto.Changeset{} = changeset) do
    changeset
    |> form_from_changeset()
    |> then(&assign(socket, :form, &1))
  end

  defp update_from_guess(%Socket{} = socket, %Guess{correct?: true} = guess) do
    socket
    |> assign(:guess, guess)
    |> update(:score, &(&1 + 1))
    |> push_patch(to: ~p"/guess/correct")
  end

  defp update_from_guess(
         %Socket{assigns: %{actual_number: actual}} = socket,
         %Guess{number: guessed} = guess
       ) do
    message = get_display_message(actual, guessed)

    socket
    |> assign(message: message, guess: guess)
    |> show_error_modal()
  end

  defp get_display_message(actual, guess) do
    if actual < guess do
      "Your guess was too high. Please try again"
    else
      "Your guess was too low. Please try again"
    end
  end

  defp show_error_modal(%Socket{assigns: %{trials: 1}} = socket),
    do: push_patch(socket, to: ~p"/guess/over")

  # When the attempt is wrong, we reset the form ( to avoid phoenix live view from
  # reusing the current changeset to dispaly the value of the input field)
  # However, we update the number of trials left
  defp show_error_modal(%Socket{} = socket) do
    socket
    |> update_trials_and_guess()
    |> reset_guess_changeset_form()
    |> push_patch(to: ~p"/guess/retry")
  end

  defp update_trials_and_guess(
         %Socket{assigns: %{guess: %{trials: trials, number: guessed}}} = socket
       ) do
    socket
    |> assign(:guessed, guessed)
    |> update(:trials, &(&1 - trials))
  end

  defp reset_guess_changeset_form(%Socket{} = socket) do
    socket
    |> add_guess()
    |> add_changeset_form()
  end

  # When a new game is requested because the guess entered is correct, we reset the game. However
  # we retain the score that the user currently has
  defp handle_new_game(%Socket{assigns: %{score: score}} = socket, dom_id, "correctly_answered") do
    hide_modal(dom_id)

    socket
    |> prepare_socket()
    |> assign(:score, score)
    |> push_patch(to: ~p"/guess")
  end

  # When the game is over, we reset the game by calling prepare_socket/1
  # before patching back to the /guess path
  defp handle_new_game(%Socket{} = socket, dom_id, "game_over") do
    hide_modal(dom_id)

    socket
    |> prepare_socket()
    |> push_patch(to: ~p"/guess")
  end
end
