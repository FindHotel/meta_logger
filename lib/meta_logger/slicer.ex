defmodule MetaLogger.Slicer do
  @moduledoc """
  Responsible for slicing log entries according to the given max length option.
  """

  @typedoc "Max length in bytes or `:infinity` if the entry should not be sliced."
  @type max_entry_length :: non_neg_integer() | :infinity

  @doc """
  Returns sliced log entries according to the given max entry length.

  If the entry is smaller than given max length, or if `:infinity ` is given
  as option, a list with one entry is returned. Otherwise a list with multiple
  entries is returned.

  ## Examples

      iex> #{inspect(__MODULE__)}.slice("1234567890", 10)
      ["1234567890"]

      iex> #{inspect(__MODULE__)}.slice("1234567890", :infinity)
      ["1234567890"]

      iex> #{inspect(__MODULE__)}.slice("1234567890", 5)
      ["12345", "67890"]

  """
  @spec slice(String.t(), max_entry_length()) :: [String.t()]
  def slice(entry, max_entry_length)
      when max_entry_length == :infinity
      when byte_size(entry) <= max_entry_length,
      do: [entry]

  def slice(entry, max_entry_length) do
    entry_length = byte_size(entry)
    rem = rem(entry_length, max_entry_length)
    sliced_entries = for <<slice::binary-size(max_entry_length) <- entry>>, do: slice

    if rem > 0 do
      remainder_entry = binary_part(entry, entry_length, rem * -1)
      sliced_entries ++ [remainder_entry]
    else
      sliced_entries
    end
  end
end
