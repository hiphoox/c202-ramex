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

  ################## tests to pass ######################
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
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :minus} end

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

  test "addition", state do
    code = """
      int main() {
        return 2+2;
    }
    """

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :addition, right_node: %AST{node_name: :constant, value: 2}} end

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == expected_result
  end

  test "substraction", state do
    code = """
      int main() {
        return 2-2;
    }
    """

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :minus, right_node: %AST{node_name: :constant, value: 2}} end

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == expected_result
  end

  test "multiplication", state do
    code = """
      int main() {
        return 2*2;
    }
    """

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :multiplication, right_node: %AST{node_name: :constant, value: 2}} end

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == expected_result
  end

  test "division", state do
    code = """
      int main() {
        return 2/2;
    }
    """

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :division, right_node: %AST{node_name: :constant, value: 2}} end

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == expected_result
  end

  test "parenthesis", state do
    code = """
      int main() {
        return (2+3)/2;
    }
    """

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :addition,
        right_node: %AST{node_name: :constant, value: 3}}, node_name: :division,
        right_node: %AST{node_name: :constant, value: 2}} end

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == expected_result
  end

  test "multiple_integration", state do
    code = """
      int main() {
        return 2*2+2/2-2;
    }
    """

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
        node_name: :multiplication, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :addition, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
        node_name: :division, right_node: %AST{node_name: :constant, value: 2}}},
        node_name: :minus, right_node: %AST{node_name: :constant, value: 2}} end

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    assert Parser.parse_program(l_code) == expected_result
  end

  test "and_integration", state do
    code = """
      int main() {
        return 2&&2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :and, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "or_integration", state do
    code = """
      int main() {
        return 2||2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :or, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "less_integration", state do
    code = """
      int main() {
        return 2<2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "greater_integration", state do
    code = """
      int main() {
        return 2>2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :greater_than, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "less_equal_integration", state do
    code = """
      int main() {
        return 2<=2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "greater_equal_integration", state do
    code = """
      int main() {
        return 2>=2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "equal_integration", state do
    code = """
      int main() {
        return 2==2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "not equal_integration", state do
    code = """
      int main() {
        return 2!=2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :not_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_plus_integration", state do
    code = """
      int main() {
        return 2+2+2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :addition, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :addition, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_minus_integration", state do
    code = """
      int main() {
        return 2-2-2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :minus, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :minus, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_multiplication_integration", state do
    code = """
      int main() {
        return 2*2*2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :multiplication, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :multiplication, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_division_integration", state do
    code = """
      int main() {
        return 2/2/2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :division, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :division, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_and_integration", state do
    code = """
      int main() {
        return 2&&2&&2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :and, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :and, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_or_integration", state do
    code = """
      int main() {
        return 2||2||2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :or, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :or, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_equal_integration", state do
    code = """
      int main() {
        return 2==2==2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :equal, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_not equal_integration", state do
    code = """
      int main() {
        return 2!=2!=2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :not_equal, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :not_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_less_integration", state do
    code = """
      int main() {
        return 2<2<2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_greater_integration", state do
    code = """
      int main() {
        return 2>2>2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :greater_than, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :greater_than, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_less equal_integration", state do
    code = """
      int main() {
        return 2<=2<=2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_greater equal_integration", state do
    code = """
      int main() {
        return 2>=2>=2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "multi_relational_integration", state do
    code = """
      int main() {
        return 2<2>2<=2>=2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "all new binary_integration", state do
    code = """
      int main() {
        return 2||2&&2==2!=2<2>2<=2>=2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :or, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :and, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :not_equal, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}}}}}} end


    assert Parser.parse_program(l_code) == expected_result
  end

  test "all operators_integration", state do
    code = """
      int main() {
        return 2||2&&2==2!=2<2>2<=2>=2+2-2*~2/!2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :or, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :and, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :not_equal, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than_equal, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :addition, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :minus, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :multiplication, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :bitwise}},
       node_name: :division, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :logical_negation}}}}}}}} end


    assert Parser.parse_program(l_code) == expected_result
  end


  ###########test to pass | unary tests#############
  test "return 2_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    assert Parser.parse_program(code) == state[:ast]
  end

  test "return 0_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 0}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]


    ast=state[:ast]

    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
       %AST{node_name: :constant, value: 0} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_digit_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 100}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]


    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{node_name: :constant, value: 100} end

    assert Parser.parse_program(code) == expected_result
  end

  test "new_lines_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 2},
      {:open_paren, 3},
      {:close_paren, 4},
      {:open_brace, 5},
      {:return_keyword, 6},
      {{:constant, 2}, 7},
      {:semicolon, 8},
      {:close_brace, 9}]



    assert Parser.parse_program(code) == state[:ast]
  end

  test "no_newlines_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 1},
      {{:constant, 2}, 1},
      {:semicolon, 1},
      {:close_brace, 1}]



    assert Parser.parse_program(code) == state[:ast]
  end

  test "negation_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {:minus, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :minus} end


    assert Parser.parse_program(code) == expected_result
  end

  test "logical_negation_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {:logical_negation, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :logical_negation} end


    assert Parser.parse_program(code) == expected_result
  end

  test "bitwise_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {:bitwise, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :bitwise} end


    assert Parser.parse_program(code) == expected_result
  end

  test "addition_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:addition, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :addition, right_node: %AST{node_name: :constant, value: 2}} end

    assert Parser.parse_program(code) == expected_result
  end

  test "substraction_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:minus, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :minus, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multiplication_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:multiplication, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :multiplication, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "division_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:division, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :division, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end



  test "parenthesis_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {:open_paren, 2},
      {{:constant, 2}, 2},
      {:addition, 2},
      {{:constant, 3}, 2},
      {:close_paren, 2},
      {:division, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :addition,
        right_node: %AST{node_name: :constant, value: 3}}, node_name: :division,
        right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multiple_binary_unarytest", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:multiplication, 2},
      {{:constant, 2}, 2},
      {:addition, 2},
      {{:constant, 2}, 2},
      {:division, 2},
      {{:constant, 2}, 2},
      {:minus, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
        node_name: :multiplication, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :addition, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
        node_name: :division, right_node: %AST{node_name: :constant, value: 2}}},
        node_name: :minus, right_node: %AST{node_name: :constant, value: 2}} end

    assert Parser.parse_program(code) == expected_result
  end

  test "and_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:and, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :and, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "or_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:or, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :or, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "less_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:less_than, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "greater_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:greater_than, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :greater_than, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "less_equal_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:less_than_equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "greater_equal_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:greater_than_equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "equal_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "not equal_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:not_equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2}, node_name: :not_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_plus_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:addition, 2},
      {{:constant, 2}, 2},
      {:addition, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :addition, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :addition, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_minus_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:minus, 2},
      {{:constant, 2}, 2},
      {:minus, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :minus, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :minus, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_multiplication_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:multiplication, 2},
      {{:constant, 2}, 2},
      {:multiplication, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :multiplication, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :multiplication, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_division_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:division, 2},
      {{:constant, 2}, 2},
      {:division, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :division, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :division, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_and_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:and, 2},
      {{:constant, 2}, 2},
      {:and, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :and, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :and, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_or_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:or, 2},
      {{:constant, 2}, 2},
      {:or, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :or, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :or, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_equal_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:equal, 2},
      {{:constant, 2}, 2},
      {:equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :equal, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_not equal_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:not_equal, 2},
      {{:constant, 2}, 2},
      {:not_equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :not_equal, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :not_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_less_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:less_than, 2},
      {{:constant, 2}, 2},
      {:less_than, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_greater_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:greater_than, 2},
      {{:constant, 2}, 2},
      {:greater_than, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :greater_than, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :greater_than, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_less equal_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:less_than_equal, 2},
      {{:constant, 2}, 2},
      {:less_than_equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_greater equal_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:greater_than_equal, 2},
      {{:constant, 2}, 2},
      {:greater_than_equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}},
        node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "multi_relational_unary", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:less_than, 2},
      {{:constant, 2}, 2},
      {:greater_than, 2},
      {{:constant, 2}, 2},
      {:less_than_equal, 2},
      {{:constant, 2}, 2},
      {:greater_than_equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "all new binary_unary test", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:or, 2},
      {{:constant, 2}, 2},
      {:and, 2},
      {{:constant, 2}, 2},
      {:equal, 2},
      {{:constant, 2}, 2},
      {:not_equal, 2},
      {{:constant, 2}, 2},
      {:less_than, 2},
      {{:constant, 2}, 2},
      {:greater_than, 2},
      {{:constant, 2}, 2},
      {:less_than_equal, 2},
      {{:constant, 2}, 2},
      {:greater_than_equal, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :or, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :and, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :not_equal, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than_equal, right_node: %AST{node_name: :constant, value: 2}}}}}} end


    assert Parser.parse_program(code) == expected_result
  end

  test "all operators_unary test", state do
    code = [
      {:int_keyword, 1},
      {:main_keyword, 1},
      {:open_paren, 1},
      {:close_paren, 1},
      {:open_brace, 1},
      {:return_keyword, 2},
      {{:constant, 2}, 2},
      {:or, 2},
      {{:constant, 2}, 2},
      {:and, 2},
      {{:constant, 2}, 2},
      {:equal, 2},
      {{:constant, 2}, 2},
      {:not_equal, 2},
      {{:constant, 2}, 2},
      {:less_than, 2},
      {{:constant, 2}, 2},
      {:greater_than, 2},
      {{:constant, 2}, 2},
      {:less_than_equal, 2},
      {{:constant, 2}, 2},
      {:greater_than_equal, 2},
      {{:constant, 2}, 2},
      {:addition, 2},
      {{:constant, 2}, 2},
      {:minus, 2},
      {{:constant, 2}, 2},
      {:multiplication, 2},
      {:bitwise, 2},
      {{:constant, 2}, 2},
      {:division, 2},
      {:logical_negation, 2},
      {{:constant, 2}, 2},
      {:semicolon, 2},
      {:close_brace, 3}]

    ast=state[:ast]
    expected_result = update_in ast, [Access.key!(:left_node), Access.key!(:left_node), Access.key!(:left_node)], fn(_left_node) ->
      %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :or, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :and, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :not_equal, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :less_than_equal, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :greater_than_equal, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :addition, right_node: %AST{node_name: :constant, value: 2}},
       node_name: :minus, right_node: %AST{left_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :multiplication, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :bitwise}},
       node_name: :division, right_node: %AST{left_node: %AST{node_name: :constant, value: 2},
       node_name: :logical_negation}}}}}}}} end


    assert Parser.parse_program(code) == expected_result
  end

  ############# tests to fail ##############
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

  test "binaryOP missing paren", _state do
    code = """
    int main() {
      return (2+2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    expected_result = {:error, "Error: close parenthesis missing at line 2"}
    assert Parser.parse_program(l_code) == expected_result
  end

  test "missing left operand", _state do
    code = """
    int main() {
      return +2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    expected_result = {:error, "Error: missing constant at line 2"}
    assert Parser.parse_program(l_code) == expected_result
  end

  test "missing right operand", _state do
    code = """
    int main() {
      return 2+;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)

    expected_result = {:error, "Error: missing constant at line 2"}
    assert Parser.parse_program(l_code) == expected_result
  end


end
