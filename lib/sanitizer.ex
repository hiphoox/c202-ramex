defmodule Sanitizer do
  @spec sanitize_source(binary) :: [binary]
  def sanitize_source(file_content) do
    str_list = String.split(file_content,"\n")
    list = Enum.with_index(str_list)
    list = Enum.filter(list,fn(x)-> elem(x,0) != "" end)
    Enum.map(list,fn x -> {String.trim(Regex.replace(~r/^\t+|\n+|\r+/,elem(x,0),"")), elem(x,1) + 1} end)
  end
end
