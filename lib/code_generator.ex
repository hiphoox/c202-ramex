defmodule CodeGenerator do
  def generate_code(ast) do
    code = post_order(ast)
    IO.puts("\nCode Generator output:")
    IO.puts(code)
    code
  end

  def post_order(node) do
    case node do
      nil ->
        nil

      ast_node ->
        code_snippet = post_order(ast_node.left_node)
        # TODO: Falta terminar de implementar cuando el arbol tiene mas ramas
        post_order(ast_node.right_node)
        emit_code(ast_node.node_name, code_snippet, ast_node.value)
    end
  end

  def emit_code(:program, code_snippet, _) do
    """
        .section        #__TEXT,__text,regular,pure_instructions
        .p2align        4, 0x90
    """ <>
      code_snippet
  end

  def emit_code(:function, code_snippet, :main) do
    """
        .globl  _main         ## -- Begin function main
    _main:                    ## @main
    """ <>
      code_snippet
      <>
      """
        ret
      """
  end

  def emit_code(:return, code_snippet, _) do
    codetoList=String.split(code_snippet, " ")
    codetoTuple=List.to_tuple(codetoList)
    const=elem(codetoTuple, 0)
    #IO.inspect(const)
    codeSpaces=String.split(code_snippet, "")
    restList=elem(List.pop_at(codeSpaces, 1), 1)
    restList2=elem(List.pop_at(restList, 1), 1)
    rest=List.to_string(restList2)
    #IO.inspect(rest)
      """
          movl    #{const}, %eax

      """ <>
      rest
  end

  def emit_code(:constant, _code_snippet, value) do
    "$#{value} "
  end

  def emit_code(:bitwise, code_snippet, _) do
    codetoList=String.split(code_snippet, " ")
    codetoTuple=List.to_tuple(codetoList)
    const=elem(codetoTuple, 0)
    number =
      case const do
        "$" <> rest ->
          rest
      end

    if number=="0" do
      code_snippet <>
      """
        movl $1, %eax
      """
    else
      code_snippet <>
      """
        movl $0, %eax
      """
    end

  end

  def emit_code(:negation, code_snippet, _) do
    code_snippet <>
    """
      neg %eax
    """
  end

  def emit_code(:logical_negation, code_snippet, _) do
    code_snippet <>
    """
      not %eax
    """
  end


end
