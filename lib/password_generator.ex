defmodule PasswordGenerator do
  @moduledoc """
  Genereate a random password depending on parameters. The module main function is `generate(options)`.
  That function takes the options map.
  Options example:
  ```
  options =%{
    "length" => "5",
    "numbers" => "false",
    "uppercase" => "false",
    "symbols" => "false"
  }
  ```
  The options are only 4, `length`, `numbers`, `uppercase`, `symbols`
  """

  # @allowed_options [:length, :numbers, :uppercase, :symbols]

  @boolean_options ["numbers", "uppercase", "lowercase", "symbols"]

  @option_types %{
    lowercase: Enum.map(?a..?z, &<<&1>>),
    numbers: Enum.map(0..9, &Integer.to_string(&1)),
    uppercase: Enum.map(?A..?Z, &<<&1>>),
    symbols: String.split("!#$%&()*+,-./:;<>=?@[]^_{|}~", "", trim: true)
  }

  @doc """
  Generates password for given options:application

  ## Examples
    options =%{
      "length" => "5",
      "numbers" => "false",
      "uppercase" => "false",
      "symbols" => "false"
    }
    iex> {:ok, _string} = PasswordGenerator.generate(%{"length" => "5"})
  """
  @spec generate(options :: map()) :: {:ok, bitstring()} | {:error, bitstring()}
  def generate(options) do
    with {:ok, _} <- validate_length(options),
         {:ok, _} <- validate_included_options(options),
         {:ok, _} <- validate_options_are_boolean(options) do
      options = Map.put(options, "lowercase", "true")
      {:ok, generate_random_strings(options)}
    end
  end

  defp validate_length(%{"length" => length} = options) do
    try do
      _int_length = String.to_integer(length)
      {:ok, options}
    rescue
      ArgumentError -> {:error, "Only integer arguments allowed for length option"}
    end
  end

  defp validate_length(_options), do: {:error, "Please provide a length"}

  defp validate_options_are_boolean(options) do
    is_valid =
      options
      |> Enum.filter(fn {key, _val} -> key in @boolean_options end)
      |> Enum.map(fn {_key, value} -> is_boolean(to_boolean(value)) end)
      |> Enum.all?()

    if is_valid do
      {:ok, options}
    else
      {:error, "Only booleans allowed for option values"}
    end
  end

  defp validate_included_options(options) do
    invalid_keys =
      options
      |> Map.delete("length")
      |> Map.keys()
      |> Enum.filter(&(&1 not in @boolean_options))

    case invalid_keys do
      [] -> {:ok, options}
      _ -> {:error, "Only valid options are numbers, uppercase, symbols."}
    end
  end

  defp generate_random_strings(options) do
    int_length = String.to_integer(options["length"])
    valid_included_options = included_options(options)

    Enum.map(1..int_length, fn _ ->
      rand_key = Enum.random(valid_included_options)
      Enum.random(@option_types[rand_key])
    end)
    |> Enum.shuffle()
    |> to_string()
  end

  defp included_options(options) do
    options
    |> Enum.filter(fn {key, value} ->
      value === "true" && key in @boolean_options
    end)
    |> Enum.map(fn {key, _value} -> String.to_atom(key) end)
  end

  defp to_boolean("true"), do: true
  defp to_boolean("false"), do: false
  defp to_boolean(val), do: val
end
