defmodule XMLParser do
  @moduledoc """
   - Uses external dependencies `:erlsom` and `Poison` to parse the XML string.
   - Used for converting the XML string given to either JSON String or Elixr.map
   - For converting XML to Elixir.map use XMLParser.parse/1 or XMLParser.parse!/1
   - For converting XML to JSON string use XMLParser.parse_to_json_string/1 or XMLParser.parse_to_json_string!/1
  """

  @doc """

  ## Examples

      iex> XMLParser.parse("<root><child1>I am child1</child1><child2><subChild>I am sub child</subChild></child2></root>")
      {:ok,
       %{
         "root" => %{
           "child1" => "I am child1",
           "child2" => %{"subChild" => "I am sub child"}
         }
       }}
  """
  def parse(xml) when is_binary(xml) do
    try do
      {:ok, convert_xml_and_parse(xml)}
    rescue
      _ ->
        {:error, "Invalid XML"}
    catch
      _ ->
        {:error, "Invalid XML"}
    end
  end

  @doc """

  ## Examples

      iex> XMLParser.parse!("<root><child1>I am child1</child1><child2><subChild>I am sub child</subChild></child2></root>")
      %{
        "root" => %{
          "child1" => "I am child1",
          "child2" => %{"subChild" => "I am sub child"}
        }
      }
  """
  def parse!(xml) when is_binary(xml) do
    convert_xml_and_parse(xml)
  end

  defp convert_xml_and_parse(xml) do
    {root, attrs, elems} =
      xml
      # removing namespaces
      |> String.replace(~r/xmlns.*?=".*?\"\s*/, "")
      # converting string to list of tuples
      |> :erlsom.simple_form()
      |> elem(1)

    root = to_string(root)
    attributes = XMLParser.Elements.format_attributes(attrs)
    elements = XMLParser.Elements.parse(%{}, elems, root, %{})
    |> Map.merge(attributes)

    %{root => Map.merge(elements, attributes)}
  end

end
