defmodule XMLParser.Elements do
  @moduledoc """
  Used for parsing the elements in the XML.
  """

  @doc """
   - `map` must be a [Map](https://hexdocs.pm/elixir/Map.html) where the elements data will be appended.
   - `elements` must be the list containing the structure [{root, attributes, elements}, ...]
   - `root` must be the binary, where the `root_value` will be created if no child-elements available.
   - `attributes` is a map where it has to be a keyword list or a [Map](https://hexdocs.pm/elixir/Map.html)

  RETURNS a [Map](https://hexdocs.pm/elixir/Map.html) which contains the elements and attributes merged as key-value pairs.
  """
  @spec parse(map, list, String.t(), Enumerable.t()) :: map
  def parse(map, elements, root, attributes)
      when is_map(map) and is_list(elements) and is_binary(root) and
             (is_map(attributes) or is_list(attributes)) do
    attributes = format_attributes(attributes)
    {root_values, orig_values} = get_element_values(elements)

    elements = elements -- orig_values

    map =
      cond do
        {root_values, attributes, elements} == {[], %{}, []} ->
          %{"#{root}_value" => ""}

        length(root_values) == 0 ->
          %{}

        length(root_values) == 1 and is_nil(map["#{root}_value"]) ->
          %{"#{root}_value" => hd(root_values)}

        length(root_values) > 1 and is_nil(map["#{root}_value"]) ->
          %{"#{root}_value" => root_values}

        length(root_values) >= 1 and !is_nil(map["#{root}_value"]) ->
          %{"#{root}_value" => List.flatten([map["#{root}_value"], root_values])}
      end
      |> Map.merge(map)

    {duplicate_elements, non_repeating_elements, duplicates} = differentiate_elements(elements)

    map = parse_non_repeated_elements(map, non_repeating_elements)

    # Parsing repeated elements (duplicates) in xml to list
    repeated_elements =
      Enum.map(duplicates, fn duplicate ->
        list =
          for {root, attrs, elements} <- duplicate_elements,
              root == duplicate,
              do: parse(%{}, elements, to_string(root), attrs)

        {List.to_string(duplicate), list}
      end)
      |> Map.new()

    Map.merge(map, repeated_elements)
    |> Map.merge(attributes)
  end

  # Used for parsing non_repeating_elements
  defp parse_non_repeated_elements(map, non_repeating_elements) do
    Enum.reduce(non_repeating_elements, map, fn {root, attrs, child_elements}, acc ->
      {element_values, orig_values} = get_element_values(child_elements)
      child_elements = child_elements -- orig_values
      root = List.to_string(root)

      attributes = format_attributes(attrs)

      elements =
        cond do
          {element_values, child_elements, attributes} == {[], [], %{}} ->
            ""

          element_values == [] and child_elements == [] and attributes != %{} ->
            attributes

          {length(element_values), child_elements, attributes} == {1, [], %{}} ->
            hd(element_values)

          length(element_values) == 1 and child_elements == [] and attributes != %{} ->
            %{"#{root}_value" => hd(element_values)} |> Map.merge(attributes)

          element_values == [] and child_elements != [] ->
            parse(%{}, child_elements, root, attrs)

          {element_values, child_elements} != {[], []} ->
            if length(element_values) == 1 do
              %{"#{root}_value" => hd(element_values)}
            else
              %{"#{root}_value" => element_values}
            end
            |> parse(child_elements, root, attrs)
        end

      Map.put(acc, root, elements)
    end)
  end

  # Filters the values from sub-elements
  defp get_element_values(elements) do
    Enum.reduce(elements, {[], []}, fn element, {root_values, orig_values} ->
      if !is_tuple(element) do
        {[to_string(element) | root_values], [element | orig_values]}
      else
        {root_values, orig_values}
      end
    end)
  end

  # Used for differentiating elements i.e duplicates and the repeated elements in xml.
  defp differentiate_elements(elements) do
    element_names = for element <- elements, is_tuple(element), do: elem(element, 0)

    unique_element_names = Enum.uniq(element_names)

    non_repeating_element_names =
      unique_element_names -- Enum.uniq(element_names -- unique_element_names)

    duplicate_element_names = unique_element_names -- non_repeating_element_names

    non_repeating_elements =
      non_repeating_element_names
      |> Enum.map(fn non_repeat ->
        Enum.filter(elements, &(elem(&1, 0) == non_repeat))
      end)
      |> List.flatten()

    duplicate_elements = elements -- non_repeating_elements
    {duplicate_elements, non_repeating_elements, duplicate_element_names}
  end

  @doc """
   - Used to format attributes for the given converted xml element

  RETURNS a [Map](https://hexdocs.pm/elixir/Map.html) containing the attributes as
  `%{"attribute_name" => "attribute_value"}`
  """
  @spec format_attributes(Enumerable.t()) :: map
  def format_attributes(attrs) do
    Enum.map(attrs, fn {k, v} -> {to_string(k), to_string(v)} end)
    |> Map.new()
  end
end
