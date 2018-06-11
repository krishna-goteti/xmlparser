defmodule XMLParserTest do
  use ExUnit.Case

  describe "parsing valid XML" do
    setup do
      xml = File.read!(Path.join(__DIR__, "xmls/test.xml"))

      {:ok, response} = XMLParser.parse(xml)
      response["root"]
    end

    test "should parse the xml to map", response do
      assert is_map(response)
    end

    test "should have child_elements", response do
      assert response["root-value"] == "\n  This is root's value\n  "
      assert is_list(response["childrenWithAttrs"])
      assert is_map(response["children1"])
    end

    test "checking childrenWithAttrs", response do
      assert length(response["childrenWithAttrs"]) == 4
      assert Map.has_key?(response, "childrenWithAttrs")
      [empty_map, child_map, no_children, one_child] = response["childrenWithAttrs"]
      # For checking whether the order is maintained.
      map = %{
        "childrenWithAttrs-value" => "\n    This will fail for sure\n    ",
        "count" => "1",
        "subChild" => [%{"no_children" => "true", "subChild-value" => "20.48", "value" => "20"}, %{"subChild-value" => ""}]
      }
      assert empty_map == map
      to_check = %{
        "count" => "2",
        "subChild" => [
          %{
            "count" => %{
              "count-value" => "1",
              "moreCounts" => "false"
            },
            "subChild-value" => "\n      Have u handled this?\n      "
          },
          %{
            "attr" => "subchild",
            "count" => [
              %{"count-value" => "1"},
              %{"count-value" => "2"}
            ],
            "innerElements" => %{
              "element1" => %{"comment" => "This is comment of inner element1"},
              "element2" => %{"comment" => "This is comment of inner element2"}
            },
            "subChild-value" => "\n      Is this handled?\n      ",
            "text" => "This is subchild's child text"
          }
        ]
      }
      assert child_map == to_check
      assert no_children == %{"no_children" => "true"}
      assert one_child == %{"subChild" => %{"value" => "21", "subChild-value" => "\n      21.48\n      "}}
    end

    test "should have the children1", response do
      assert Map.has_key?(response, "children1")
      count_list = [
        %{"count-value" => "1"},
        %{"count-value" => "2" },
        %{"count-value" => "3"},
        %{"count-value" => "4"}
      ]
      assert get_in(response, ["children1", "count"]) == count_list
      assert get_in(response, ["children1", "children1-value"]) == ["\n    This is children1's second value\n  ", "\n    This is children1's value\n    "]
    end

  end

  test "parsing invalid XML" do
    xml = File.read!(Path.join(__DIR__, "xmls/invalidXML.xml"))

    assert XMLParser.parse(xml) == {:error, "Invalid XML"}
    catch_throw(XMLParser.parse!(xml))
    catch_throw(XMLParser.parse!(""))
  end

end
