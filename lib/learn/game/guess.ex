defmodule Learn.Games.Guess do
  @moduledoc false
  import Ecto.Changeset

  defstruct [:number, trials: 0, correct?: false]

  @type t :: %__MODULE__{
          number: pos_integer(),
          trials: pos_integer(),
          correct?: boolean()
        }

  @types %{number: :integer, trials: :integer, correct?: :boolean}

  @doc false
  def changeset(guess, attrs) do
    {guess, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required(:number, message: "guess is required")
    |> validate_inclusion(:number, 1..9, message: "guess must be a number between 1 and 9")
  end

  @doc false
  def check_guess_changeset(guess, attrs, actual_number) do
    guess
    |> changeset(attrs)
    |> check_if_correct(actual_number)
  end

  defp check_if_correct(
         %Ecto.Changeset{valid?: true, changes: %{number: guessed}, data: data} = changeset,
         actual_number
       ) do
    if correct? = guessed == actual_number do
      put_change(changeset, :correct?, correct?)
    else
      put_change(changeset, :trials, data.trials + 1)
    end
  end

  defp check_if_correct(changeset, _number), do: changeset
end
