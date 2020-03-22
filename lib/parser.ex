defmodule Parser do
  def parse_program(token_list) do
    function = parse_function(token_list)
    #IO.inspect(function)

    case function do
      {{:error, error_message}, _rest} ->
        {:error, error_message}

      {function_node, rest} ->
        if rest == [] do
          %AST{node_name: :program, left_node: function_node}
        else
          {:error, "Error: there are more elements after function end"}
        end
    end
  end

  def parse_function([tup_token | rest]) do
    next_token=elem(tup_token, 0)
    lineInt=elem(tup_token, 1)
    #lineInt=Enum.join(elem(tup_token, 1)," ")
    #IO.inspect(tup_token)
    #IO.puts(next_token)
    #IO.inspect(line)
    if next_token == :int_keyword do
      #IO.inspect(next_token)
      #new_string=elem(next_token, 0)
      [tup_token | rest] = rest
      next_token=elem(tup_token,0)
      lineMain=elem(tup_token, 1)
      #lineMain=Enum.join(elem(tup_token, 1)," ")
      #IO.inspect(tup_token)
      #IO.inspect(next_token)
      #IO.inspect(rest)

      if next_token == :main_keyword do
        [tup_token | rest] = rest
        next_token=elem(tup_token,0)
        lineOparen=elem(tup_token, 1)
        #lineOparen=Enum.join(elem(tup_token, 1)," ")
        #IO.inspect(tup_token)
        #IO.inspect(next_token)
        #IO.inspect(rest)

        if next_token == :open_paren do
          [tup_token | rest] = rest
          next_token=elem(tup_token,0)
          lineCparen=elem(tup_token, 1)
          #lineCparen=Enum.join(elem(tup_token, 1)," ")

          if next_token == :close_paren do
            [tup_token | rest] = rest
            next_token=elem(tup_token,0)
            lineObrace=elem(tup_token, 1)
            #lineObrace=Enum.join(elem(tup_token, 1)," ")

            if next_token == :open_brace do
              statement = parse_statement(rest)

              case statement do
                {{:error, error_message}, rest} ->
                  {{:error, error_message}, rest}

                {statement_node, [tup_token | rest]} ->
                  next_token=elem(tup_token, 0)
                  lineCbrace=elem(tup_token, 1)
                  #lineCbrace=Enum.join(elem(tup_token, 1)," ")
                  if next_token == :close_brace do
                    {%AST{node_name: :function, value: :main, left_node: statement_node}, rest}
                  else
                    {{:error, "Error, close brace missed in line " <> Integer.to_string(lineCbrace)}, rest}
                  end
              end
            else
              {:error, "Error: open brace missed in line " <> Integer.to_string(lineObrace)}
            end
          else
            {:error, "Error: close parentesis missed in line " <> Integer.to_string(lineCparen)}
          end
        else
          {:error, "Error: open parentesis missed in line " <> Integer.to_string(lineOparen)}
        end
      else
        {:error, "Error: main function missed in line " <> Integer.to_string(lineMain)}
      end
    else
      {:error, "Error, return type value missed in line " <> Integer.to_string(lineInt)}
    end
  end

  def parse_statement([tup_token | rest]) do
    next_token=elem(tup_token, 0)
    lineRet=elem(tup_token, 1)
    #lineRet=Enum.join(elem(tup_token, 1)," ")
    #IO.inspect(next_token)
    if next_token == :return_keyword do
      expression = parse_expression(rest)
      #IO.inspect(next_token)
      #IO.inspect(expression)

      case expression do
        {{:error, error_message}, rest} ->
          {{:error, error_message}, rest}

        {exp_node, [tup_token | rest]} ->
          next_token=elem(tup_token,0)
          lineSemicolon=elem(tup_token, 1)
          #IO.puts(next_token)
          #IO.puts(lineSemicolon)
          #lineSemicolon=Enum.join(elem(tup_token, 1)," ")
          if next_token == :semicolon do
            {%AST{node_name: :return, left_node: exp_node}, rest}
          else
            #IO.puts("llego al error")
            #IO.inspect({:error,"errror" <> Integer.to_string(lineSemicolon)})
            {{:error, "Error: semicolon missed after constant to finish return statement in line " <> Integer.to_string(lineSemicolon)}, rest}
          end
      end
    else
      {{:error, "Error: return keyword missed in line " <> Integer.to_string(lineRet)}, rest}
    end
  end

  @spec parse_expression(nonempty_maybe_improper_list) ::
          {{:error, <<_::64, _::_*8>>} | AST.t(), any}
  def parse_expression([tup_token | rest]) do
    next_token=elem(tup_token, 0)
    lineConstant=elem(tup_token, 1)
    #lineConstant=Enum.join(elem(tup_token, 1)," ")
    #IO.puts(lineConstant)

    case next_token do
      {:constant, value} -> {%AST{node_name: :constant, value: value}, rest}
      _ -> {{:error, "Error: constant value missed in line " <> Integer.to_string(lineConstant)}, rest}
    end
  end
end
