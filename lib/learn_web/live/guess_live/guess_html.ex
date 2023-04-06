defmodule LearnWeb.GuessLive.GuessHtml do
  @moduledoc """

  """

  use LearnWeb, :html

  embed_templates "guess_html/*"

  @doc """
  Function component for rendering the guess form
  """
  attr :form, :map, required: true

  attr :points, :integer,
    required: true,
    doc: "The total number of points that the user currently has earned"

  attr :actual_number, :integer,
    required: true,
    doc: "The actual number that is the user is supposed to guess"

  def guess_form(assigns)

  @doc """
  Renders the retry modal for when the user provides a wrong guess
  """
  attr :retries, :integer, required: true, doc: "The number of attempts the user has to guess"

  attr :guessed_number, :integer,
    required: true,
    doc: "The number that the user entered as their guess"

  attr :message, :string,
    required: true,
    doc: "The message to display to the user on a wrong attempt"

  def retry_modal(assigns)

  @doc """
  Renders the correct modal for when the user provides the correct guess
  """

  attr :points, :integer, required: true, doc: "The total points the user currently has earned"

  attr :guessed_number, :integer,
    required: true,
    doc: "The number that the user entered as their guess"

  def correct_modal(assigns)

  @doc """
  Renders the game over modal for when a user has entered the wrong guess 3 times
  """
  attr :points, :integer, required: true, doc: "The total number of points earned by the user"

  def game_over_modal(assigns)
end
