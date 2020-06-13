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
        .section        __TEXT,__text,regular,pure_instructions
        .p2align        4, 0x90
    """ <>
      code_snippet
  end

  def emit_code(:function, code_snippet, :main, _, _) do
    """
        .globl  main         ## -- Begin function main
    main:                    ## @main
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
          mov    #{const}, %rax

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
        mov $1, %rax
      """
    else
      code_snippet <>
      """
         not %rax
      """
    end

  end

  def emit_code(:minus, code_snippet, _, code_snippet_right, _) do

    case code_snippet_right do
      nil ->

        code_snippet <>
        """
           neg %rax
        """
      _ ->
        codetoList=String.split(code_snippet_right, " ")
        codetoTuple=List.to_tuple(codetoList)
        const=elem(codetoTuple, 0)

        codeSpaces=String.split(code_snippet_right, "")
        restList=elem(List.pop_at(codeSpaces, 1), 1)
        restList2=elem(List.pop_at(restList, 1), 1)
        rest=List.to_string(restList2)

        code_snippet <>
        """
           push %rax
        """ <> "    mov " <> const <>
        ", %rax
    " <> rest <>
        """
        pop %rcx
            sub %rcx, %rax
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
        mov $1, %rax
      """
    else
      code_snippet <>
      """
        mov $0, %rax
      """
    end
  end

  def emit_code(:addition, code_snippet, _, code_snippet_right, _) do
    codetoList=String.split(code_snippet_right, " ")
    codetoTuple=List.to_tuple(codetoList)
    const=elem(codetoTuple, 0)

    codeSpaces=String.split(code_snippet_right, "")
    restList=elem(List.pop_at(codeSpaces, 1), 1)
    restList2=elem(List.pop_at(restList, 1), 1)
    rest=List.to_string(restList2)

    code_snippet <>
    """
       push %rax
    """ <> "    mov " <> const <>
    ", %rax
    " <> rest <>
    """
    pop %rcx
        add %rcx, %rax
    """
  end

  def emit_code(:multiplication, code_snippet, _, code_snippet_right, _) do
    codetoList=String.split(code_snippet_right, " ")
    codetoTuple=List.to_tuple(codetoList)
    const=elem(codetoTuple, 0)

    codeSpaces=String.split(code_snippet_right, "")
    restList=elem(List.pop_at(codeSpaces, 1), 1)
    restList2=elem(List.pop_at(restList, 1), 1)
    rest=List.to_string(restList2)

    code_snippet <>
    """
       push %rax
    """ <> "    mov " <> const <>
    ", %rax
    " <> rest <>
    """
    pop %rcx
        imul %rcx, %rax
    """
  end

  def emit_code(:division, code_snippet, _, code_snippet_right, _) do
    codetoList=String.split(code_snippet_right, " ")
    codetoTuple=List.to_tuple(codetoList)
    const=elem(codetoTuple, 0)

    codeSpaces=String.split(code_snippet_right, "")
    restList=elem(List.pop_at(codeSpaces, 1), 1)
    restList2=elem(List.pop_at(restList, 1), 1)
    rest=List.to_string(restList2)

    code_snippet <>
    """
       push %rax
        cdq
    """ <> "    mov " <> const <>
    ", %rax
    " <> rest <>
    """
    pop %rcx
        idivq %rcx
    """
  end

  def emit_code(:equal, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %rax
    """ <> "    mov " <> code_snippet_right <>
    ", %rax
    " <>
    """
    pop %rcx
        cmp %rax, %rcx
        mov $0, %rax
        sete %al
    """
  end

  def emit_code(:not_equal, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %rax
    """ <> "    mov " <> code_snippet_right <>
    ", %rax
    " <>
    """
    pop %rcx
        cmp %rax, %rcx
        mov $0, %rax
        setne %al
    """
  end

  def emit_code(:less_than, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %rax
    """ <> "    mov " <> code_snippet_right <>
    ", %rax
    " <>
    """
    pop %rcx
        cmp %rax, %rcx
        mov $0, %rax
        setl %al
    """
  end

  def emit_code(:greater_than, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %rax
    """ <> "    mov " <> code_snippet_right <>
    ", %rax
    " <>
    """
    pop %rcx
        cmp %rax, %rcx
        mov $0, %rax
        setg %al
    """
  end

  def emit_code(:less_than_equal, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %rax
    """ <> "    mov " <> code_snippet_right <>
    ", %rax
    " <>
    """
    pop %rcx
        cmp %rax, %rcx
        mov $0, %rax
        setle %al
    """
  end

  def emit_code(:greater_than_equal, code_snippet, _, code_snippet_right, _) do
    code_snippet <>
    """
       push %rax
    """ <> "    mov " <> code_snippet_right <>
    ", %rax
    " <>
    """
    pop %rcx
        cmp %rax, %rcx
        mov $0, %rax
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
       cmp $0, %rax
    """ <> "    je _clause" <> to_string(Counter.click(pid))
    <>
    "
    mov $1, %rax
    jmp _end" <> to_string(Counter.get(pid))
    <> "
_clause" <> to_string(Counter.get(pid)) <> ":
" <> "    mov #{const} , %rax
   "
          <> rest <>
    """
    cmp $0, %rax
        mov $0, %rax
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
       cmp $0, %rax
    """ <> "    jne _clause" <> to_string(Counter.click(pid))
    <>
    "
    jmp _end" <> to_string(Counter.get(pid))
    <> "
_clause" <> to_string(Counter.get(pid)) <> ":
" <> "    mov #{const} , %rax
"
     <> rest <>

    """
       cmp $0, %rax
        mov $0, %rax
        setne %al
    """ <> "_end" <> to_string(Counter.get(pid)) <> ":
    "
  end

end
