defmodule Nqcc do
  @moduledoc """
  Documentation for Nqcc.
  """
  @commands %{
    "\t-h\t" => "help",
    "\t-s\t" => "Generate Assembler\n\n\n"
  }

  def main(args) do
    #args
    #|> parse_args
    case args do
    ["-h"] -> print_help_message()
    ["-c",file_name] -> compile_file(file_name)
    ["-s",file_name] -> print_assembler(file_name)
    end
  end

 # def parse_args(args) do
  #  OptionParser.parse(args, switches: [help: :boolean])
  #end



  defp print_assembler(file_path) do
    IO.puts("\nGenerate Assembly code:\n" <> file_path)

    with {:ok, contentF} <- File.read(file_path),
    sanitizedList when not is_tuple(sanitizedList) <- Sanitizer.sanitize_source(contentF),
    lexedList when not is_tuple(lexedList) <- Lexer.scan_words(sanitizedList),
    parsedAST when not is_tuple(parsedAST) <- Parser.parse_program(lexedList),
    codeAssembly when not is_tuple(codeAssembly) <- CodeGenerator.generate_code(parsedAST)
    do
     {:ok, "Assembler code generated correctly"}
    else
      error -> IO.inspect(error)
    end
  end

  defp compile_file(file_path) do
    IO.puts("Compiling file: " <> file_path)
    assembly_path = String.replace_trailing(file_path, ".c", ".s")

    with {:ok, contentF} <- File.read(file_path),
     sanitizedList when not is_tuple(sanitizedList) <- Sanitizer.sanitize_source(contentF),
     IO.inspect(sanitizedList, label: "\nSanitizer output"),
     lexedList when not is_tuple(lexedList) <- Lexer.scan_words(sanitizedList),
     IO.inspect(lexedList, label: "\nLexer ouput"),
     parsedAST when not is_tuple(parsedAST) <- Parser.parse_program(lexedList),
     IO.inspect(parsedAST, label: "\nParser ouput"),
     codeAssembly when not is_tuple(codeAssembly) <- CodeGenerator.generate_code(parsedAST),
     #IO.inspect(codeAssembly)
     :ok <- Linker.generate_binary(codeAssembly, assembly_path)
     do
      {:ok, "compilation complete"}
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

  defp print_help_message do
    IO.puts("\nThe compiler supports following options:\n")

    @commands
    |> Enum.map(fn {command, description} -> IO.puts("  #{command} - #{description}") end)
  end
end
