defmodule CodeGenerator do
  def generate_code(ast) do

    code = post_order(ast)

    code
  end

  def post_order(node) do
    case node do
      nil ->
        nil

      ast_node ->

        code_snippet = post_order(ast_node.left_node)

        code_snippet_right = post_order(ast_node.right_node)

        emit_code(ast_node.node_name, code_snippet, ast_node.value, code_snippet_right)
    end
  end

  def emit_code(:program, code_snippet, _, _) do
    """
        .section        #__TEXT,__text,regular,pure_instructions
        .p2align        4, 0x90
    """ <>
      code_snippet
  end

  def emit_code(:function, code_snippet, :main, _) do
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

  def emit_code(:return, code_snippet, _, _) do
    codetoList=String.split(code_snippet, " ")
    codetoTuple=List.to_tuple(codetoList)
    const=elem(codetoTuple, 0)

    codeSpaces=String.split(code_snippet, "")
    restList=elem(List.pop_at(codeSpaces, 1), 1)
    restList2=elem(List.pop_at(restList, 1), 1)
    rest=List.to_string(restList2)

      """
          movl    #{const}, %eax
      """ <>
      rest
  end

  def emit_code(:constant, _code_snippet, value, _) do
    "$#{value} "
  end


  def emit_code(:bitwise, code_snippet, _, _) do
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
         not %eax
      """
    end

  end

  def emit_code(:minus, code_snippet, _, code_snippet_right) do

    case code_snippet_right do
      nil ->

        code_snippet <>
        """
           neg %eax
        """
      _ ->
        code_snippet <>
        """
           push %eax
        """ <> "    movl " <> code_snippet_right <>
        ", %eax
    " <>
        """
        pop %ecx
            subl %ecx, %eax
        """
    end
  end

  def emit_code(:logical_negation, code_snippet, _, _) do
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

  def emit_code(:addition, code_snippet, _, code_snippet_right) do
    code_snippet <>
    """
       push %eax
    """ <> "    movl " <> code_snippet_right <>
    ", %eax
    " <>
    """
    pop %ecx
        addl %ecx, %eax
    """
  end

  def emit_code(:multiplication, code_snippet, _, code_snippet_right) do
    code_snippet <>
    """
       push %eax
    """ <> "    movl " <> code_snippet_right <>
    ", %eax
    " <>
    """
    pop %ecx
        imul %ecx, %eax
    """
  end

  def emit_code(:division, code_snippet, _, code_snippet_right) do
    code_snippet <>
    """
       push %eax
        cdq
    """ <> "    movl " <> code_snippet_right <>
    ", %eax
    " <>
    """
    pop %ecx
        idivl %ecx
    """
  end

end
