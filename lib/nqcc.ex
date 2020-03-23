defmodule Nqcc do
  @moduledoc """
  Documentation for Nqcc.
  """
  @commands %{
    "\t-h\t" => "help\n\t\t\t\tSintaxis:\n\t\t\t\t\tWindows: escript nqcc -h",
    "\t-c\t" => "Compiler the program\n\t\t\t\tSintaxis:\n\t\t\t\t\tWindows: escript nqcc -c 'Example Adress'",
    "\t-a\t" => "Generate Assembler\n\t\t\t\tSintaxis:\n\t\t\t\t\tWindows: escript nqcc -a 'Example Adress'",
    "\t-t\t" => "Generate AST tree\n\t\t\t\tSintaxis:\n\t\t\t\t\tWindows: escript nqcc -t 'Example Adress'",
    "\t-l\t" => "Token List\n\t\t\t\tSintaxis:\n\t\t\t\t\tWindows: escript nqcc -l 'Example Adress'"
  }

  def main(args) do
    #args
    #|> parse_args
    case args do
    ["-h"] -> print_help_message()
    ["-c",file_name] -> compile_file(file_name)
    ["-l",file_name] -> token_list(file_name)
    ["-t",file_name] -> ast_tree(file_name)
    ["-a",file_name] -> print_assembler(file_name)
    end
  end

 # def parse_args(args) do
  #  OptionParser.parse(args, switches: [help: :boolean])
  #end



  defp print_assembler(file_path) do
    IO.puts("\nGenerate Assembly code:\t" <> file_path)

    with {:ok, contentF} <- File.read(file_path),
    sanitizedList when not is_tuple(sanitizedList) <- Sanitizer.sanitize_source(contentF),
    lexedList when not is_tuple(lexedList) <- Lexer.scan_words(sanitizedList),
    parsedAST when not is_tuple(parsedAST) <- Parser.parse_program(lexedList),
    codeAssembly when not is_tuple(codeAssembly) <- CodeGenerator.generate_code(parsedAST)
    do
     {:ok, IO.puts("Assembler code generated correctly")}
    else
      error -> IO.inspect(error)
    end
  end

  defp compile_file(file_path) do
    IO.puts("Compiling file:\t " <> file_path)
    assembly_path = String.replace_trailing(file_path, ".c", ".s")

    with {:ok, contentF} <- File.read(file_path),
     sanitizedList when not is_tuple(sanitizedList) <- Sanitizer.sanitize_source(contentF),
     IO.inspect(sanitizedList, label: "\nSanitizer output"),
     lexedList when not is_tuple(lexedList) <- Lexer.scan_words(sanitizedList),
     IO.inspect(lexedList, label: "\nLexer ouput"),
     parsedAST when not is_tuple(parsedAST) <- Parser.parse_program(lexedList),
     IO.inspect(parsedAST, label: "\nParser ouput"),
     codeAssembly when not is_tuple(codeAssembly) <- CodeGenerator.generate_code(parsedAST),
     #IO.puts(codeAssembly),
     Linker.generate_binary(codeAssembly, assembly_path)
     do
      {:ok, IO.puts("compilation complete\n")}
     else
      error -> IO.inspect(error)
    end
    #File.read!(file_path)
    #|> Sanitizer.sanitize_source()
    #|> IO.inspect(label: "\nSanitizer ouput")
    #|> Lexer.scan_words()
    #|> IO.inspect(label: "\nLexer ouput")
    #|> Parser.parse_program()
    #|> IO.inspect(label: "\nParser ouput")
    #|> CodeGenerator.generate_code()
    #|> Linker.generate_binary(assembly_path)
  end

  def token_list(file_path) do
    IO.puts("\nToken List:\t" <> file_path)

    with {:ok, contentF} <- File.read(file_path),
    sanitizedList when not is_tuple(sanitizedList) <- Sanitizer.sanitize_source(contentF),
    lexedList when not is_tuple(lexedList) <- Lexer.scan_words(sanitizedList),
    IO.inspect(lexedList, label: "\nLexer ouput")
    do
     {:ok, IO.puts("Token List generated correctly")}
    else
      error -> IO.inspect(error)
    end
  end

  def ast_tree(file_path) do
    IO.puts("\nAST tree:\t" <> file_path)

    with {:ok, contentF} <- File.read(file_path),
    sanitizedList when not is_tuple(sanitizedList) <- Sanitizer.sanitize_source(contentF),
    lexedList when not is_tuple(lexedList) <- Lexer.scan_words(sanitizedList),
    parsedAST when not is_tuple(parsedAST) <- Parser.parse_program(lexedList),
    IO.inspect(parsedAST, label: "\nParser ouput:")
    do
      {:ok, IO.puts("AST tree generated correctly")}
     else
       error -> IO.inspect(error)
     end
  end


  defp print_help_message do
    IO.puts("\nThe compiler supports following options:\n")

    @commands
    |> Enum.map(fn {command, description} -> IO.puts("  #{command} - #{description}") end)
  end
end
