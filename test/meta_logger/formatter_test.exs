defmodule MetaLogger.FormatterTest do
  use ExUnit.Case

  alias MetaLogger.Formatter, as: Subject

  describe "format/1" do
    test "accepts a correct struct and returns a formatted data" do
      formatted_log =
        %{be: "good", to: "the world"}
        |> FormatterProtocolTest.build()
        |> Subject.format()

      assert formatted_log == ["good", "the world"]
    end

    test "filters elements by a given pattern" do
      formatted_log =
        %{be: "bad", to: "the world"}
        |> FormatterProtocolTest.build()
        |> Subject.format()

      assert formatted_log == ["[FILTERED]", "the world"]
    end

    test "when filters given as tuples, uses given replacement instead a default one" do
      formatted_log =
        %{be: "good", to: ~s/{"name":"John"}/}
        |> FormatterProtocolTest.build()
        |> Subject.format()

      assert formatted_log == ["good", ~s/{"name":"[FILTERED]"}/]
    end

    test "when there is wrong struct given, raises an error" do
      defmodule WrongStruct do
        defstruct [:a]
      end

      assert_raise(Protocol.UndefinedError, fn ->
        Subject.format(WrongStruct)
      end)
    end

    test "when a payload for format function is incorrect, raises the error" do
      defmodule IncorrectStruct do
        @derive {Subject, formatter_fn: &__MODULE__.format/1}
        defstruct [:payload]
        def format(%{b: b}), do: b
      end

      my_struct = struct!(IncorrectStruct, payload: %{a: "1"})

      assert_raise(MetaLogger.Formatter.IncorrectPayload, fn ->
        Subject.format(my_struct)
      end)
    end

    test "when formatter function is not set, raises the error" do
      error =
        assert_raise(MetaLogger.Formatter.IncorrectOrNotSetFormatterFunction, fn ->
          defmodule IncorrectDerivedStruct do
            @derive Subject
            defstruct [:payload]
          end
        end)

      assert error.message =~
               "Formatter function must be provided, e.g. @derive {MetaLogger.Formatter, formatter_fn: &__MODULE__.format/1}"
    end
  end
end
