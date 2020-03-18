defmodule Lexer do
  def scan_words(words) do
      text=Enum.map(words, fn {string, _} -> string end)
      line=Enum.map(words, fn {_, number} -> number end)
      textString=Enum.join(text, " ")
      #IO.inspect(text)
      trimmed_content = String.trim(textString)
      sal=Regex.split(~r/\s+/, trimmed_content)
      #IO.inspect(sal)
      Enum.flat_map(sal, &lex_raw_tokens(&1, line))

  end


  @spec get_constant(binary) :: {:error | {:constant, any}, binary}
  def get_constant(program) do
    case Regex.run(~r/^\d+/, program) do
      [value] ->
        {{:constant, String.to_integer(value)}, String.trim_leading(program, value)}

      program ->
        {:error, "Token not valid: #{program}"}
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
  def lex_raw_tokens(program,line) when program != "" do
      #IO.puts(program)

    {token, rest} =
      case program do
        "{" <> rest ->
          {:open_brace, rest}

        "}" <> rest ->
          {:close_brace, rest}

        "(" <> rest ->
          {:open_paren, rest}

        ")" <> rest ->
          {:close_paren, rest}

        ";" <> rest ->
          {:semicolon, rest}

        "return" <> rest ->
          {:return_keyword, rest}

        "int" <> rest ->
          {:int_keyword, rest}

        "main" <> rest ->
          {:main_keyword, rest}

        rest ->
          get_constant(rest)
      end

    if token != :error do
      remaining_tokens = lex_raw_tokens(rest,line)
      [token | remaining_tokens]
    else
      [:error]
    end
  end

  def lex_raw_tokens(_program,_line) do
    []
  end
end
