defmodule XMLParser do
  @moduledoc """
   - Uses external dependencies [:erlsom](https://github.com/willemdj/erlsom) to parse the XML string.
   - For converting XML to [Map](https://hexdocs.pm/elixir/Map.html) use `XMLParser.parse/1` or `XMLParser.parse!/1`
  """

  @doc """
  - Parses the XML string given to the [Map](https://hexdocs.pm/elixir/Map.html).
  - Returns {:ok, result} on success, else returns {:error, "Invalid XML"}.

  ## Examples

      iex> xml = \"\"\"
      <root>
        <child1>I am child1</child1>
        <child2>
          <subChild>I am sub child</subChild>
        </child2>
      </root>
      \"\"\"
      iex> XMLParser.parse(xml)
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
  - Parses the XML string given to the [Map](https://hexdocs.pm/elixir/Map.html), raises / throws an exception on error.

  ## Examples

      iex> xml = \"\"\"
      <root>
        <child1>I am child1</child1>
        <child2>
          <subChild>I am sub child</subChild>
        </child2>
      </root>
      \"\"\"
      iex> XMLParser.parse!(xml)
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
