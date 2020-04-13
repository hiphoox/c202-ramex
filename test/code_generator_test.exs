defmodule CodeGeneratorTest do
  use ExUnit.Case
  doctest Lexer

  setup_all do
    {:ok, assembly: """
        .section        #__TEXT,__text,regular,pure_instructions
        .p2align        4, 0x90
        .globl  _main         ## -- Begin function main
    _main:                    ## @main
        movl    $2, %eax

       ret
    """}
  end

  #test to pass
  test "ret 2", state do
    code = """
      int main() {
        return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    p_code = Parser.parse_program(l_code)
    assert CodeGenerator.generate_code(p_code) == state[:assembly]
  end

  test "ret 0", state do
    code = """
      int main() {
        return 0;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    p_code = Parser.parse_program(l_code)

    _previous_result=state[:assembly]
    expected_result="""
    .section        #__TEXT,__text,regular,pure_instructions
    .p2align        4, 0x90
    .globl  _main         ## -- Begin function main
_main:                    ## @main
    movl    $0, %eax

   ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "neg", state do
    code = """
      int main() {
        return -2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    p_code = Parser.parse_program(l_code)

    _previous_result=state[:assembly]
    expected_result="""
    .section        #__TEXT,__text,regular,pure_instructions
    .p2align        4, 0x90
    .globl  _main         ## -- Begin function main
_main:                    ## @main
    movl    $2, %eax

   neg %eax
  ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "logicNeg0", state do
    code = """
      int main() {
        return !0;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    p_code = Parser.parse_program(l_code)

    _previous_result=state[:assembly]
    expected_result="""
    .section        #__TEXT,__text,regular,pure_instructions
    .p2align        4, 0x90
    .globl  _main         ## -- Begin function main
_main:                    ## @main
    movl    $0, %eax

   movl $1, %eax
  ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "logicNeg_not0", state do
    code = """
      int main() {
        return !5;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    p_code = Parser.parse_program(l_code)

    _previous_result=state[:assembly]
    expected_result="""
    .section        #__TEXT,__text,regular,pure_instructions
    .p2align        4, 0x90
    .globl  _main         ## -- Begin function main
_main:                    ## @main
    movl    $5, %eax

   movl $0, %eax
  ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "bitwise_0", state do
    code = """
      int main() {
        return ~0;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    p_code = Parser.parse_program(l_code)

    _previous_result=state[:assembly]
    expected_result="""
    .section        #__TEXT,__text,regular,pure_instructions
    .p2align        4, 0x90
    .globl  _main         ## -- Begin function main
_main:                    ## @main
    movl    $0, %eax

   movl $1, %eax
  ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "bitwise_not0", state do
    code = """
      int main() {
        return ~2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    p_code = Parser.parse_program(l_code)

    _previous_result=state[:assembly]
    expected_result="""
    .section        #__TEXT,__text,regular,pure_instructions
    .p2align        4, 0x90
    .globl  _main         ## -- Begin function main
_main:                    ## @main
    movl    $2, %eax

   not %eax
  ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "multiple_operators", state do
    code = """
      int main() {
        return ---2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)
    l_code = Lexer.scan_words(s_code)
    p_code = Parser.parse_program(l_code)

    _previous_result=state[:assembly]
    expected_result="""
    .section        #__TEXT,__text,regular,pure_instructions
    .p2align        4, 0x90
    .globl  _main         ## -- Begin function main
_main:                    ## @main
    movl    $2, %eax

   neg %eax
  neg %eax
  neg %eax
  ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end



end
