defmodule Parser do
  @spec parse_program(nonempty_maybe_improper_list) :: {:error, <<_::64, _::_*8>>} | AST.t()
  def parse_program(token_list) do
    function = parse_function(token_list)


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

  @spec parse_function(nonempty_maybe_improper_list) ::
          {:error | {:error, <<_::64, _::_*8>>} | AST.t(), any}
  def parse_function([tup_token | rest]) do
    next_token=elem(tup_token, 0)
    lineInt=elem(tup_token, 1)

    if next_token == :int_keyword do

      [tup_token | rest] = rest
      next_token=elem(tup_token,0)
      lineMain=elem(tup_token, 1)


      if next_token == :main_keyword do
        [tup_token | rest] = rest
        next_token=elem(tup_token,0)
        lineOparen=elem(tup_token, 1)


        if next_token == :open_paren do
          [tup_token | rest] = rest
          next_token=elem(tup_token,0)
          lineCparen=elem(tup_token, 1)


          if next_token == :close_paren do
            [tup_token | rest] = rest
            next_token=elem(tup_token,0)
            lineObrace=elem(tup_token, 1)


            if next_token == :open_brace do
              statement = parse_statement(rest)

              case statement do
                {{:error, error_message}, rest} ->
                  {{:error, error_message}, rest}

                {statement_node, [tup_token | rest]} ->
                  next_token=elem(tup_token, 0)
                  lineCbrace=elem(tup_token, 1)

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

    if next_token == :return_keyword do

      expression = parse_expression(rest)



      case expression do
        {{:error, error_message}, rest} ->
          {{:error, error_message}, rest}

        {exp_node, [tup_token | rest]} ->
          next_token=elem(tup_token,0)
          lineSemicolon=elem(tup_token, 1)

          if next_token == :semicolon do
            {%AST{node_name: :return, left_node: exp_node}, rest}
          else

            {{:error, "Error: semicolon missed after constant to finish return statement in line " <> Integer.to_string(lineSemicolon)}, rest}
          end
      end
    else
      {{:error, "Error: return keyword missed in line " <> Integer.to_string(lineRet)}, rest}
    end
  end



  def parse_expression([tup_token | rest]) do
    out=while_expression([tup_token | rest], nil)

    tree=elem(out, 0)
    rest=elem(out, 1)


        {tree, rest}



  end

  @spec while_expression(nonempty_maybe_improper_list, any) :: {any, nonempty_maybe_improper_list}
  def while_expression([tup_token | rest], tree) do

    term=while_term([tup_token | rest], tree)

    left=elem(term, 0)
    rest=elem(term, 1)

    [tup_token | rest] = rest
    next_token=elem(tup_token, 0)

    if next_token == :addition do

      term=while_term(rest, tree)

      right=elem(term, 0)
      rest=elem(term, 1)

      new_tree=%AST{node_name: :addition, left_node: left, right_node: right}

      [tup_token | rst] = rest
      next_token=elem(tup_token, 0)

      if next_token == :addition do

        tree_rest=while_expression(rst, new_tree)
        tree=elem(tree_rest, 0)
        rest=elem(tree_rest, 1)
          {%AST{node_name: :addition, left_node: new_tree, right_node: tree}, rest}

      else
        if next_token == :minus do

          tree_rest=while_expression(rst, new_tree)
          tree=elem(tree_rest, 0)
          rest=elem(tree_rest, 1)
          {%AST{node_name: :minus, left_node: new_tree, right_node: tree}, rest}

        else

          {new_tree, rest}
        end
      end
    else
      if next_token == :minus do

        term=while_term(rest, tree)
        right=elem(term, 0)
        rest=elem(term, 1)
        new_tree=%AST{node_name: :minus, left_node: left, right_node: right}
        [tup_token | rst] = rest
        next_token=elem(tup_token, 0)

        if next_token == :addition do
          tree_rest=while_expression(rst, new_tree)
          tree=elem(tree_rest, 0)
          rest=elem(tree_rest, 1)
          {%AST{node_name: :addition, left_node: new_tree, right_node: tree}, rest}

        else
          if next_token == :minus do
            tree_rest=while_expression(rst, new_tree)
            tree=elem(tree_rest, 0)
            rest=elem(tree_rest, 1)
            {%AST{node_name: :minus, left_node: new_tree, right_node: tree}, rest}


          else
            {new_tree, rest}
          end
        end



      else
        {left, [tup_token | rest]}
      end

    end

  end





  def while_term([tup_token | rest], _tree) do

    term=parse_factor([tup_token | rest])
    left=elem(term, 0)
    rest=elem(term, 1)
    [tup_token | rest] = rest
    next_token=elem(tup_token, 0)

    if next_token == :multiplication do

      term=parse_factor(rest)
      right=elem(term, 0)
      rest=elem(term, 1)
      new_tree=%AST{node_name: :multiplication, left_node: left, right_node: right}
      [tup_token | rst] = rest
      next_token=elem(tup_token, 0)
      if next_token == :multiplication do
        tree_rest=while_term(rst, new_tree)
        tree=elem(tree_rest, 0)
        rest=elem(tree_rest, 1)
        {%AST{node_name: :multiplication, left_node: new_tree, right_node: tree}, rest}

      else
        if next_token == :division do
          tree_rest=while_term(rst, new_tree)
          tree=elem(tree_rest, 0)
          rest=elem(tree_rest, 1)
          {%AST{node_name: :division, left_node: new_tree, right_node: tree}, rest}

        else
          {new_tree, rest}
        end
      end

    else
      if next_token == :division do

        term=parse_factor(rest)
        right=elem(term, 0)
        rest=elem(term, 1)
        new_tree=%AST{node_name: :division, left_node: left, right_node: right}
        [tup_token | rst] = rest
        next_token=elem(tup_token, 0)
        if next_token == :multiplication do
          tree_rest=while_term(rst, new_tree)
          tree=elem(tree_rest, 0)
          rest=elem(tree_rest, 1)
          {%AST{node_name: :multiplication, left_node: new_tree, right_node: tree}, rest}

        else
          if next_token == :division do
            tree_rest=while_term(rst, new_tree)
            tree=elem(tree_rest, 0)
            rest=elem(tree_rest, 1)
            {%AST{node_name: :division, left_node: new_tree, right_node: tree}, rest}

          else
            {new_tree, rest}
          end
        end


      else

        {left, [tup_token | rest]}
      end
    end

  end



  @spec parse_factor(nonempty_maybe_improper_list) :: {AST.t(), any}
  def parse_factor([tup_token | rest]) do

    next_token=elem(tup_token, 0)
    line_con=elem(tup_token, 1)

    case next_token do
      :open_paren ->
        expression = parse_expression(rest)
        tree=elem(expression, 0)
        rest=elem(expression, 1)
        [tup_token | rest] = rest
        next_token_tmp=elem(tup_token,0)
        lineCloseParen=elem(tup_token, 1)
        if next_token_tmp != :close_paren do
          {{:error, "Error: close parenthesis missing at line " <> Integer.to_string(lineCloseParen)}, rest}
        else
        {tree, rest}
        end
      :minus ->

        [tup_token | rest] = rest
        factor=parse_factor([tup_token | rest])
        constant_node=elem(factor,0)
        rest=elem(factor, 1)

        {%AST{node_name: :minus, left_node: constant_node}, rest}
      :bitwise ->
        [tup_token | rest] = rest
        factor=parse_factor([tup_token | rest])
        constant_node=elem(factor, 0)
        rest=elem(factor, 1)
        {%AST{node_name: :bitwise, left_node: constant_node}, rest}
      :logical_negation ->
        [tup_token | rest] = rest
        #next_token_tmp=elem(tup_token,0)
        factor=parse_factor([tup_token | rest])
        constant_node=elem(factor,0)
        rest=elem(factor, 1)
        {%AST{node_name: :logical_negation, left_node: constant_node}, rest}
      {:constant, value} ->

        {%AST{node_name: :constant, value: value}, rest}
      _ ->
        {{:error, "Error: missing constant at line " <> Integer.to_string(line_con)}, rest}

    end
  end
end
