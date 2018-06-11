defmodule XMLParser.Elements do

  @doc """
   - Used for parsing the elements in the XML.
   - `map`: must be the `Elixir.Map` where the elements data will be appended.
   - `elements`: must be the list containing the structure [{root, attributes, elements}, ...]
   - `root`: must be the binary, where the `root-value` will be created if no child-elements available.
   - `attributes`: is a map where it has to be a keyword list or a `Elixir.Map`

  RETURNS a map which contains the elements and attributes merged as key-value pairs.
  """
  def parse(map, elements, root, attributes)
    when is_map(map) and is_list(elements) and is_binary(root) and (is_map(attributes) or is_list(attributes)) do

    attributes = format_attributes(attributes)
    {root_values, orig_values} = get_element_values(elements)

    elements = elements -- orig_values
    map = cond do
      {root_values, attributes, elements} == {[], %{}, []} ->
        %{"#{root}-value" => ""}
      length(root_values) == 0 ->
        %{}
      length(root_values) == 1 and is_nil(map["#{root}-value"]) ->
        %{"#{root}-value" => hd(root_values)}
      length(root_values) > 1 and is_nil(map["#{root}-value"]) ->
        %{"#{root}-value" => root_values}
      length(root_values) >= 1 and !(is_nil(map["#{root}-value"])) ->
        %{"#{root}-value" => List.flatten([map["#{root}-value"], root_values])}
    end |> Map.merge(map)
    {duplicate_elements, non_repeating_elements, duplicates} =
      differentiate_elements(elements)

    map = parse_non_repeated_elements(map, non_repeating_elements)

    # Parsing repeated elements (duplicates) in xml to list
    repeated_elements = Enum.map(duplicates, fn(duplicate)->
      list =
        duplicate_elements
        |> Enum.filter(&(elem(&1, 0) == duplicate))
        |> Enum.map(&(parse(%{}, elem(&1, 2), to_string(elem(&1, 0)), elem(&1, 1))))
      {List.to_string(duplicate), list}
    end) |> Map.new()

    Map.merge(map, repeated_elements)
    |> Map.merge(attributes)
  end

  # Used for parsing non_repeating_elements
  defp parse_non_repeated_elements(map, non_repeating_elements) do
    Enum.reduce(non_repeating_elements, map, fn({root, attrs, child_elements}, acc)->
      {element_values, orig_values} = get_element_values(child_elements)
      child_elements = child_elements -- orig_values
      root = List.to_string(root)

      attributes = format_attributes(attrs)
      elements = cond do
        {element_values, child_elements, attributes} == {[], [], %{}} ->
          ""
        element_values == [] and child_elements == [] and attributes != %{} ->
          attributes
        {length(element_values), child_elements, attributes} == {1, [], %{}} ->
          hd(element_values)
        length(element_values) == 1 and child_elements == [] and attributes != %{}->
          %{"#{root}-value" => hd(element_values)} |> Map.merge(attributes)
        element_values == [] and child_elements != [] ->
          parse(%{}, child_elements, root, attrs)
        {element_values, child_elements} != {[], []} ->
          if length(element_values) == 1 do
            %{"#{root}-value" => hd(element_values)}
          else
            %{"#{root}-value" => element_values}
          end |> parse(child_elements, root, attrs)
      end
      Map.put(acc, root, elements)
    end)
  end

  # Filters the values from sub-elements
  defp get_element_values(elements) do
    Enum.reduce(elements, {[], []}, fn(element, {root_values, orig_values}) ->
      if !is_tuple(element) do
        {[to_string(element) | root_values], [element | orig_values]}
      else
        {root_values, orig_values}
      end
    end)
  end

  # Used for differentiating elements i.e duplicates and the repeated elements in xml.
  defp differentiate_elements(elements) do
    element_names =
      elements
      |> Enum.filter(&is_tuple/1)
      |> Enum.map(&(elem(&1, 0)))

    unique_element_names = Enum.uniq(element_names)

    non_repeating_element_names =
      unique_element_names -- Enum.uniq(element_names -- unique_element_names)

    duplicate_element_names = unique_element_names -- non_repeating_element_names

    non_repeating_elements =
      non_repeating_element_names
      |> Enum.map(fn(non_repeat) ->
        Enum.filter(elements, &(elem(&1, 0) == non_repeat))
      end)
      |> List.flatten()
    duplicate_elements = elements -- non_repeating_elements
    {duplicate_elements, non_repeating_elements, duplicate_element_names}
  end

  @doc """
   - Used to format attributes for the given converted xml element

  RETURNS a map containing the attributes as below
  %{"attribute_name" => "attribute_value"}
  """
  def format_attributes(attrs) do
    Enum.map(attrs, fn {k, v} -> {to_string(k), to_string(v)} end)
    |> Map.new()
  end
end