defmodule CodeGenerator do
  def generate_code(ast) do

    #c("Counter.ex")
    c=Counter.new
    code = post_order(ast, c)

    code
  end

  def post_order(node, pid) do
    case node do
      nil ->
        nil

      ast_node ->

        code_snippet = post_order(ast_node.left_node, pid)

        code_snippet_right = post_order(ast_node.right_node, pid)

        emit_code(ast_node.node_name, code_snippet, ast_node.value, code_snippet_right, pid)
    end
  end

  def emit_code(:program, code_snippet, _, _, _) do
    """
        .section        #__TEXT,__text,regular,pure_instructions
        .p2align        4, 0x90
    """ <>
      code_snippet
  end

  def emit_code(:function, code_snippet, :main, _, _) do
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

  def emit_code(:return, code_snippet, _, _, _) do
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

  def emit_code(:constant, _code_snippet, value, _, _) do
    "$#{value} "
  end


  def emit_code(:bitwise, code_snippet, _, _, _) do
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

  def emit_code(:minus, code_snippet, _, code_snippet_right, _) do

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

  def emit_code(:logical_negation, code_snippet, _, _, _) do
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

  def emit_code(:addition, code_snippet, _, code_snippet_right, _) do
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

  def emit_code(:multiplication, code_snippet, _, code_snippet_right, _) do
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

  def emit_code(:division, code_snippet, _, code_snippet_right, _) do
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

  def emit_code(:equal, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %eax
    """ <> "    movl " <> code_snippet_right <>
    ", %eax
    " <>
    """
    pop %ecx
        cmpl %eax, %ecx
        movl $0, %eax
        sete %al
    """
  end

  def emit_code(:not_equal, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %eax
    """ <> "    movl " <> code_snippet_right <>
    ", %eax
    " <>
    """
    pop %ecx
        cmpl %eax, %ecx
        movl $0, %eax
        setne %al
    """
  end

  def emit_code(:less_than, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %eax
    """ <> "    movl " <> code_snippet_right <>
    ", %eax
    " <>
    """
    pop %ecx
        cmpl %eax, %ecx
        movl $0, %eax
        setl %al
    """
  end

  def emit_code(:greater_than, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %eax
    """ <> "    movl " <> code_snippet_right <>
    ", %eax
    " <>
    """
    pop %ecx
        cmpl %eax, %ecx
        movl $0, %eax
        setg %al
    """
  end

  def emit_code(:less_than_equal, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %eax
    """ <> "    movl " <> code_snippet_right <>
    ", %eax
    " <>
    """
    pop %ecx
        cmpl %eax, %ecx
        movl $0, %eax
        setle %al
    """
  end

  def emit_code(:greater_than_equal, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %eax
    """ <> "    movl " <> code_snippet_right <>
    ", %eax
    " <>
    """
    pop %ecx
        cmpl %eax, %ecx
        movl $0, %eax
        setge %al
    """
  end

  def emit_code(:or, code_snippet, _, code_snippet_right, pid) do
    codetoList=String.split(code_snippet_right, " ")
    codetoTuple=List.to_tuple(codetoList)
    const=elem(codetoTuple, 0)

    codeSpaces=String.split(code_snippet_right, "")
    restList=elem(List.pop_at(codeSpaces, 1), 1)
    restList2=elem(List.pop_at(restList, 1), 1)
    rest=List.to_string(restList2)

    code_snippet <>
    """
       cmpl $0, %eax
    """ <> "    je _clause" <> to_string(Counter.click(pid))
    <>
    "
    movl $1, %eax
    jmp _end" <> to_string(Counter.get(pid))
    <> "
_clause" <> to_string(Counter.get(pid)) <> ":
" <> "    movl #{const} , %eax
   "
          <> rest <>
    """
    cmpl $0, %eax
        movl $0, %eax
        setne %al
    """ <> "_end" <> to_string(Counter.get(pid)) <> ":
    "
  end

  def emit_code(:and, code_snippet, _, code_snippet_right, pid) do
    codetoList=String.split(code_snippet_right, " ")
    codetoTuple=List.to_tuple(codetoList)
    const=elem(codetoTuple, 0)

    codeSpaces=String.split(code_snippet_right, "")
    restList=elem(List.pop_at(codeSpaces, 1), 1)
    restList2=elem(List.pop_at(restList, 1), 1)
    rest=List.to_string(restList2)

    code_snippet <>
    """
       cmpl $0, %eax
    """ <> "    jne _clause" <> to_string(Counter.click(pid))
    <>
    "
    jmp _end" <> to_string(Counter.get(pid))
    <> "
_clause" <> to_string(Counter.get(pid)) <> ":
" <> "    movl #{const} , %eax
"
     <> rest <>

    """
       cmpl $0, %eax
        movl $0, %eax
        setne %al
    """ <> "_end" <> to_string(Counter.get(pid)) <> ":
    "
  end

end
