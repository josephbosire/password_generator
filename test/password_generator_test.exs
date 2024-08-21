defmodule PasswordGeneratorTest do
  use ExUnit.Case
  doctest PasswordGenerator

  setup do
    options = %{
      "length" => "10",
      "numbers" => "false",
      "uppercase" => "false",
      "symbols" => "false"
    }

    options_type = %{
      lowercase: Enum.map(?a..?z, &<<&1>>),
      numbers: Enum.map(0..9, &Integer.to_string(&1)),
      uppercase: Enum.map(?A..?Z, &<<&1>>),
      symbols: String.split("!#$%&()*+,-./:;<>=?@[]^_{|}~", "", trim: true)
    }

    %{options_type: options_type, options: options}
  end

  test "returns a string", %{options: options} do
    {:ok, result} = PasswordGenerator.generate(options)
    assert is_bitstring(result)
  end

  test "returns error when no length is given" do
    options = %{"invalid" => "false"}
    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns an error when the length is not an integer" do
    options = %{"length" => "ab"}
    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "length of returned is string is the option provided", %{options: options} do
    length_option = %{"length" => "5"}
    {:ok, result} = PasswordGenerator.generate(length_option)
    assert 5 = String.length(result)
  end

  test "returns a lowercase string just with the length", %{options_type: options_type} do
    lowercase_length_options = %{"length" => "5", "lowercase" => "true"}
    {:ok, result} = PasswordGenerator.generate(lowercase_length_options)
    assert String.contains?(result, options_type.lowercase)
    refute String.contains?(result, options_type.numbers)
    refute String.contains?(result, options_type.uppercase)
    refute String.contains?(result, options_type.symbols)
  end

  test "returns error when option values are not booleans" do
    options = %{
      "length" => "10",
      "numbers" => "invalid",
      "uppercase" => "0",
      "symbols" => "false"
    }

    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when options not allowed" do
    options = %{"length" => "5", "invalid" => "true"}
    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when 1 option not allowed" do
    options = %{"length" => "5", "numbers" => "true", "invalid" => "true"}
    assert {:error, _error} = PasswordGenerator.generate(options)
  end
end
