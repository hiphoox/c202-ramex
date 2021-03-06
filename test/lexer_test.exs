defmodule LexerTest do
  use ExUnit.Case
  doctest Lexer

  setup_all do
    {:ok,
     tokens: [
       {:int_keyword, 1},
       {:main_keyword, 1},
       {:open_paren, 1},
       {:close_paren, 1},
       {:open_brace, 1},
       {:return_keyword, 2},
       {{:constant, 2}, 2},
       {:semicolon, 2},
       {:close_brace, 3}
     ]}
  end

  # tests to pass
  test "return 2", state do
    code = """
      int main() {
        return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:tokens]
  end



  test "return 0", state do
    code = """
      int main() {
        return 0;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 6, fn _ -> {{:constant, 0}, 2} end)
    assert Lexer.scan_words(s_code) == expected_result
  end


  test "multi_digit", state do
    code = """
      int main() {
        return 100;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 6, fn _ -> {{:constant, 100}, 2} end)
    assert Lexer.scan_words(s_code) == expected_result
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

    expected_result=
    state[:tokens]
    |> List.update_at(1, fn _ -> {:main_keyword, 2} end)
    |> List.update_at(2, fn _ -> {:open_paren, 3} end)
    |> List.update_at(3, fn _ -> {:close_paren, 4} end)
    |> List.update_at(4, fn _ -> {:open_brace, 5} end)
    |> List.update_at(5, fn _ -> {:return_keyword, 6} end)
    |> List.update_at(6, fn _ -> {{:constant, 2}, 7} end)
    |> List.update_at(7, fn _ -> {:semicolon, 8} end)
    |> List.update_at(8, fn _ -> {:close_brace, 9} end)


    assert Lexer.scan_words(s_code) == expected_result
  end



  test "no_newlines", state do
    code = """
    int main(){return 2;}
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result=
      state[:tokens]
      |> List.update_at(5, fn _ -> {:return_keyword, 1} end)
      |> List.update_at(6, fn _ -> {{:constant, 2}, 1} end)
      |> List.update_at(7, fn _ -> {:semicolon, 1} end)
      |> List.update_at(8, fn _ -> {:close_brace, 1} end)

    assert Lexer.scan_words(s_code) == expected_result
  end



  test "spaces", state do
    code = """
    int   main    (  )  {   return  2 ; }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result=
      state[:tokens]
      |> List.update_at(5, fn _ -> {:return_keyword, 1} end)
      |> List.update_at(6, fn _ -> {{:constant, 2}, 1} end)
      |> List.update_at(7, fn _ -> {:semicolon, 1} end)
      |> List.update_at(8, fn _ -> {:close_brace, 1} end)

    assert Lexer.scan_words(s_code) == expected_result
  end

  test "elements separated just by spaces", state do
    expected_result=
      state[:tokens]
      |> List.update_at(5, fn _ -> {:return_keyword, 1} end)
      |> List.update_at(6, fn _ -> {{:constant, 2}, 1} end)
      |> List.update_at(7, fn _ -> {:semicolon, 1} end)
      |> List.update_at(8, fn _ -> {:close_brace, 1} end)

    assert Lexer.scan_words([{"int", 1}, {"main(){return", 1}, {"2;}", 1}]) == expected_result
  end


  test "function name separated of function body", state do
    expected_result=
      state[:tokens]
      |> List.update_at(5, fn _ -> {:return_keyword, 1} end)
      |> List.update_at(6, fn _ -> {{:constant, 2}, 1} end)
      |> List.update_at(7, fn _ -> {:semicolon, 1} end)
      |> List.update_at(8, fn _ -> {:close_brace, 1} end)

    assert Lexer.scan_words([{"int", 1}, {"main()", 1}, {"{return", 1}, {"2;}", 1}]) == expected_result
  end

  test "everything is separated", state do
    expected_result=
      state[:tokens]
      |> List.update_at(5, fn _ -> {:return_keyword, 1} end)
      |> List.update_at(6, fn _ -> {{:constant, 2}, 1} end)
      |> List.update_at(7, fn _ -> {:semicolon, 1} end)
      |> List.update_at(8, fn _ -> {:close_brace, 1} end)

    assert Lexer.scan_words([{"int", 1}, {"main", 1}, {"(", 1}, {")", 1}, {"{", 1}, {"return", 1}, {"2", 1}, {";", 1}, {"}", 1}]) ==
             expected_result
  end

  test "negation", state do
    code = """
      int main() {
        return -2;
    }
    """

    expected_result=List.insert_at(state[:tokens],6, {:minus, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "logic_negation", state do
    code = """
      int main() {
        return !2;
    }
    """

    expected_result=List.insert_at(state[:tokens],6, {:logical_negation, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "bitwise", state do
    code = """
      int main() {
        return ~2;
    }
    """

    expected_result=List.insert_at(state[:tokens],6, {:bitwise, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "plus_tkn", state do
    code = """
      int main() {
        return 2+2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:addition, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "substraction_tkn", state do
    code = """
      int main() {
        return 2-2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:minus, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "multiplication_tkn", state do
    code = """
      int main() {
        return 2*2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:multiplication, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "division_tkn", state do
    code = """
      int main() {
        return 2/2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:division, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "and_tkn", state do
    code = """
      int main() {
        return 2&&2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:and, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "or_tkn", state do
    code = """
      int main() {
        return 2||2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:or, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "less_tkn", state do
    code = """
      int main() {
        return 2<2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:less_than, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "less_equal_tkn", state do
    code = """
      int main() {
        return 2<=2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:less_than_equal, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "greater_tkn", state do
    code = """
      int main() {
        return 2>2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:greater_than, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "greater_equal_tkn", state do
    code = """
      int main() {
        return 2>=2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:greater_than_equal, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "equal_tkn", state do
    code = """
      int main() {
        return 2==2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:equal, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "not equal_tkn", state do
    code = """
      int main() {
        return 2!=2;
    }
    """
    expected_result=
    List.insert_at(state[:tokens],7, {:not_equal, 2})
    |> List.insert_at(8, {{:constant, 2}, 2})

    s_code = Sanitizer.sanitize_source(code)
    assert Lexer.scan_words(s_code) == expected_result
  end

  # tests to fail
  test "wrong case", _state do
    code = """
    int main() {
      RETURN 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "token not valid", _state do
    code = """
    int main() {
      return $;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "token not valid at other line", _state do
    code = """
    int main() {
      return
      %2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "wrong type", _state do
    code = """
    void main() {
      return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "misspelled main", _state do
    code = """
    int min() {
      return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end

    #########unary tests###########
  test "wrong case_unary test", _state do

    s_code = [{"int", 1}, {"main", 1}, {"(", 1}, {")", 1}, {"{", 1}, {"RETURN", 2}, {"2", 2}, {";", 2}, {"}", 3}]

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "token not valid_unary test", _state do

    s_code = [{"int", 1}, {"main", 1}, {"(", 1}, {")", 1}, {"{", 1}, {"return", 2}, {"$", 2}, {";", 2}, {"}", 3}]

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "token not valid at other line_unary test", _state do


    s_code = [{"int", 1}, {"main", 1}, {"(", 1}, {")", 1}, {"{", 1}, {"RETURN", 2}, {"$", 3}, {";", 3}, {"}", 4}]

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "wrong type_unary test", _state do

    s_code = [{"void", 1}, {"main", 1}, {"(", 1}, {")", 1}, {"{", 1}, {"return", 2}, {"2", 2}, {";", 2}, {"}", 3}]

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "misspelled main_unary test", _state do

    s_code = [{"int", 1}, {"min", 1}, {"(", 1}, {")", 1}, {"{", 1}, {"return", 2}, {"2", 2}, {";", 2}, {"}", 3}]

    expected_result = {:error}
    assert Lexer.scan_words(s_code) == expected_result
  end
end
