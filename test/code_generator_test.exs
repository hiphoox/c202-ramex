defmodule CodeGeneratorTest do
  use ExUnit.Case
  doctest Lexer

  setup_all do
    {:ok, assembly: """
        .section        #__TEXT,__text,regular,pure_instructions
        .p2align        4, 0x90
        .globl  _main         ## -- Begin function main
    _main:                    ## @main
        mov    $2, %rax

         ret
    """}
  end

  ############# test to pass ##############
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
    mov    $0, %rax

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
    mov    $2, %rax

    neg %rax
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
    mov    $0, %rax

   mov $1, %rax
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
    mov    $5, %rax

   mov $0, %rax
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
    mov    $0, %rax

   mov $1, %rax
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
    mov    $2, %rax

    not %rax
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
    mov    $2, %rax

    neg %rax
   neg %rax
   neg %rax
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_addition", state do
    code = """
      int main() {
        return 2+2;
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
    mov    $2, %rax

    push %rax
    mov $2, %rax\r
     pop %rcx
    add %rcx, %rax
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_substraction", state do
    code = """
      int main() {
        return 2-2;
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
    mov    $2, %rax

    push %rax
    mov $2, %rax\r
     pop %rcx
    sub %rcx, %rax
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_multiplication", state do
    code = """
      int main() {
        return 2*2;
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
    mov    $2, %rax

    push %rax
    mov $2, %rax\r
     pop %rcx
    imul %rcx, %rax
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_division", state do
    code = """
      int main() {
        return 2/2;
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
    mov    $2, %rax

    push %rax
    cdq
    mov $2, %rax\r
     pop %rcx
    idivq %rcx
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_equal", state do
    code = """
      int main() {
        return 2==2;
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
    mov    $2, %rax

    push %rax
    mov $2 , %rax\r
    pop %rcx
    cmpl %rax, %rcx
    mov $0, %rax
    sete %al
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_Not equal", state do
    code = """
      int main() {
        return 2!=2;
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
    mov    $2, %rax

    push %rax
    mov $2 , %rax\r
    pop %rcx
    cmpl %rax, %rcx
    mov $0, %rax
    setne %al
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_less", state do
    code = """
      int main() {
        return 2<2;
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
    mov    $2, %rax

    push %rax
    mov $2 , %rax\r
    pop %rcx
    cmpl %rax, %rcx
    mov $0, %rax
    setl %al
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_less or equal", state do
    code = """
      int main() {
        return 2<=2;
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
    mov    $2, %rax

    push %rax
    mov $2 , %rax\r
    pop %rcx
    cmpl %rax, %rcx
    mov $0, %rax
    setle %al
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_greater", state do
    code = """
      int main() {
        return 2>2;
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
    mov    $2, %rax

    push %rax
    mov $2 , %rax\r
    pop %rcx
    cmpl %rax, %rcx
    mov $0, %rax
    setg %al
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_greater or equal", state do
    code = """
      int main() {
        return 2>=2;
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
    mov    $2, %rax

    push %rax
    mov $2 , %rax\r
    pop %rcx
    cmpl %rax, %rcx
    mov $0, %rax
    setge %al
    ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_or", state do
    code = """
      int main() {
        return 1||0;
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
    mov    $1, %rax

    cmpl $0, %rax
    je _clause1\r
    mov $1, %rax\r
    jmp _end1\r
_clause1:\r
    mov $0 , %rax\r
    cmpl $0, %rax
    mov $0, %rax
    setne %al
_end1:\r
        ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_and", state do
    code = """
      int main() {
        return 1&&0;
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
    mov    $1, %rax

    cmpl $0, %rax
    jne _clause1\r
    jmp _end1\r
_clause1:\r
    mov $0 , %rax\r
    cmpl $0, %rax
    mov $0, %rax
    setne %al
_end1:\r
        ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

  test "asm_addition and", state do
    code = """
      int main() {
        return 2+2&&2;
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
    mov    $2, %rax

    push %rax
    mov $2, %rax\r
     pop %rcx
    add %rcx, %rax
   cmpl $0, %rax
    jne _clause1\r
    jmp _end1\r
_clause1:\r
    mov $2 , %rax\r
    cmpl $0, %rax
    mov $0, %rax
    setne %al
_end1:\r
        ret
"""

    assert CodeGenerator.generate_code(p_code) == expected_result
  end

end
