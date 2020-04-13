defmodule ParserTest do
  use ExUnit.Case
  doctest Lexer

  setup_all do
    {:ok,
     ast: %AST{
      left_node: %AST{
        left_node: %AST{
          left_node: %AST{
            left_node: nil,
            node_name: :constant,
            right_node: nil,
            value: 2
          },
          node_name: :return,
          right_node: nil,
          value: nil
        },
        node_name: :function,
        right_node: nil,
        value: :main
      },
      node_name: :program,
      right_node: nil,
      value: nil
    }}
  end

  # tests to pass
  test "return 2", state do
    code = """
      int main() {
        return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == state[:ast]
  end

  test "return 0", state do
    code = """
      int main() {
        return 0;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    ast=state[:ast]

    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
       %AST{node_name: :constant, value: 0} end

    #expected_result = List.update_at(state[:ast], 6, fn _ -> {{:constant, 0}, 2} end)
    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_digit", state do
    code = """
      int main() {
        return 100;
    }
    """
    ast=state[:ast]
    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{node_name: :constant, value: 100} end

    assert Parser.parse_program(l_code) == expected_result
  end

  test "new_lines", state do
    code = """
    int
    main
    (
    )
    {
    return
    2
    ;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    assert Parser.parse_program(l_code) == state[:ast]
  end

  test "no_newlines", state do
    code = """
    int main(){return 2;}
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    assert Parser.parse_program(l_code) == state[:ast]
  end

  test "spaces", state do
    code = """
    int   main    (  )  {   return  2 ; }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    assert Parser.parse_program(l_code) == state[:ast]
  end

  test "negation", state do
    code = """
      int main() {
        return -2;
    }
    """

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :negation} end

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == expected_result
  end

  test "logical_negation", state do
    code = """
      int main() {
        return !2;
    }
    """

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :logical_negation} end

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == expected_result
  end

  test "bitwise", state do
    code = """
      int main() {
        return ~2;
    }
    """

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :bitwise} end

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == expected_result
  end

  # tests to fail
  test "constant missing", _state do
    code = """
    int main() {
      return ;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    expected_result = {:error, "Error: missing constant at line 2"}
    assert Parser.parse_program(l_code) == expected_result
  end

  test "semicolon missing", _state do
    code = """
    int main() {
      return 2
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    expected_result = {:error, "Error: semicolon missed after constant to finish return statement in line 3"}
    assert Parser.parse_program(l_code) == expected_result
  end

  test "more after function", _state do
    code = """
    int main() {
      return 2;
    }}}
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    expected_result = {:error, "Error: there are more elements after function end"}
    assert Parser.parse_program(l_code) == expected_result
  end
end
