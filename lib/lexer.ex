defmodule Lexer do
  def scan_words(words) do
      text=Enum.map(words, fn {string, _} -> string end)
      line=Enum.map(words, fn {_, number} -> number end)


      text
      |> Enum.zip(line)
      |> Enum.flat_map(&lex_raw_tokens(elem(&1, 0), elem(&1, 1)))
      |> check_error()


  end

  @spec check_error(any) :: any
  def check_error(listLex) do
    if Enum.find_value(listLex, false, fn(x)->x==:error end)==true do
      {:error}

  else
    listLex
  end
  end

  @spec get_constant(binary, any) :: {:error | {:constant, any}, any, binary}
  def get_constant(program, line) do

    invalid=program
    case Regex.run(~r/^\d+/, program) do
      [value] ->
        {{:constant, String.to_integer(value)}, line, String.trim_leading(program, value)}

      program ->
        #{:error, line, "Token not valid: #{program}"}
        IO.inspect({:error, invalid, "token not valid at line: " <> to_string(line)})
        {:error, line, "Token not valid: #{program}"}
    end
  end

  @spec lex_raw_tokens(any,any) :: [
          :close_brace
          | :close_paren
          | :error
          | :int_keyword
          | :main_keyword
          | :open_brace
          | :open_paren
          | :return_keyword
          | :semicolon
          | {:constant, any}
        ]
  def lex_raw_tokens(program,line) when program != "" and not is_tuple(program) do

      trimmed_content = String.trim(program)
      sal=String.replace(trimmed_content, " ","")

    {token, lin, rest} =
      case sal do
        "{" <> rest ->
          {:open_brace, line, rest}

        "}" <> rest ->
          {:close_brace, line, rest}

        "(" <> rest ->
          {:open_paren, line, rest}

        ")" <> rest ->
          {:close_paren, line, rest}

        ";" <> rest ->
          {:semicolon, line, rest}

        "return" <> rest ->
          {:return_keyword, line, rest}

        "int" <> rest ->
          {:int_keyword, line, rest}

        "main" <> rest ->
          {:main_keyword, line, rest}

        "-" <> rest ->
          {:minus, line, rest}

        "~" <> rest ->
          {:bitwise, line, rest}

        "!=" <> rest ->
          {:not_equal, line, rest}

        "!" <> rest ->
          {:logical_negation, line, rest}

        "+" <> rest ->
          {:addition, line, rest}

        "*" <> rest ->
          {:multiplication, line, rest}

        "/" <> rest ->
          {:division, line, rest}

        "&&" <> rest ->
          {:and, line, rest}

        "||" <> rest ->
          {:or, line, rest}

        "==" <> rest ->
          {:equal, line, rest}

        "<=" <> rest ->
          {:less_than_equal, line, rest}

        ">=" <> rest ->
          {:greater_than_equal, line, rest}

        "<" <> rest ->
          {:less_than, line, rest}

        ">" <> rest ->
          {:greater_than, line, rest}

        rest ->
          get_constant(rest, line)
      end
    if token != :error do


      remaining_tokens = lex_raw_tokens(rest,line)


      [{token, lin} | remaining_tokens]


    else

      [:error]
    end
  end

  def lex_raw_tokens(_program,_line) do
    []
  end
end
