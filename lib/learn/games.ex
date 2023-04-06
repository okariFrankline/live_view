defmodule Learn.Games do
  @moduledoc false

  alias __MODULE__.Guess

  @doc false
  def change_guess(guess \\ %Guess{}, attrs) do
    Guess.changeset(guess, attrs)
  end

  @doc false
  def check_guess(guess, attrs, actual_number) do
    guess
    |> Guess.check_guess_changeset(attrs, actual_number)
    |> Ecto.Changeset.apply_action(:insert)
  end
end
