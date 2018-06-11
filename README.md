# XMLParser

XMLParser is the XML library for Elixir which mainly focused on parsing the XML given to the Elixir.Map for processing the XMl-API responses.

## Installation

Add the below configuration in your mix.exs to install this dependency

```elixir
def deps do
  [
    {:xmlparser, "~> 0.1.0"},
    #... other dependencies
  ]
end
```

Run the below to get this dependency in your application.

```sh-session
$ mix deps.get
```

## Usage
```elixir
xml = "<note><to>Tove</to><from>Jani</from><heading>Reminder</heading><body>Don't forget me this weekend!</body></note>"

XMLParser.parse(xml)

#=>
{:ok,
 %{
   "note" => %{
     "body" => "Don't forget me this weekend!",
     "from" => "Jani",
     "heading" => "Reminder",
     "to" => "Tove"
   }
 }
}

XMLParser.parse!(xml)

#=>
%{
  "note" => %{
    "body" => "Don't forget me this weekend!",
    "from" => "Jani",
    "heading" => "Reminder",
    "to" => "Tove"
  }
}
```
## More Examples

```elixir
xml = """
<books>
	<book>
		<name>Harry Potter Paperback Box Set (Books 1-7)</name>
		<price>$52.16</price>
		<description>Harry Potter is a series of fantasy novels written by British author J. K. Rowling.</description>
	</book>
	<book>
		<name>The Complete Illustrated Sherlock Holmes</name>
		<price>$2.46</price>
		<description>Sherlock Holmes is a fictional private detective created by British author Sir Arthur Conan Doyle.</description>
	</book>
	<book>
		<name>Wonder</name>
		<price>$10.70</price>
		<description>Wonder is a children's novel by Raquel Jaramillo, under the pen name of R. J. Palacio</description>
	</book>
	<book>
		<name>Shiva Trilogy</name>
		<price>$14.86</price>
		<description>The Shiva Trilogy is a series of three fantasy myth novels by an Indian author Amish Tripathi, released annually from 2010 to 2013</description>
	</book>
	<book>
		<name>The Righteous Mind</name>
		<price>$12.18</price>
		<description>The Righteous Mind: Why Good People are Divided by Politics and Religion is a 2012 social psychology book by the social psychologist Jonathan Haidt, in which the author describes human morality as it relates to politics and religion.</description>
	</book>
</books>
"""
XMLParser.parse!(xml)

#=>
%{
  "books" => %{
    "book" => [
      %{
        "description" => "Harry Potter is a series of fantasy novels written by British author J. K. Rowling.",
        "name" => "Harry Potter Paperback Box Set (Books 1-7)",
        "price" => "$52.16"
      },
      %{
        "description" => "Sherlock Holmes is a fictional private detective created by British author Sir Arthur Conan Doyle.",
        "name" => "The Complete Illustrated Sherlock Holmes",
        "price" => "$2.46"
      },
      %{
        "description" => "Wonder is a children's novel by Raquel Jaramillo, under the pen name of R. J. Palacio",
        "name" => "Wonder",
        "price" => "$10.70"
      },
      %{
        "description" => "The Shiva Trilogy is a series of three fantasy myth novels by an Indian author Amish Tripathi, released annually from 2010 to 2013",
        "name" => "Shiva Trilogy",
        "price" => "$14.86"
      },
      %{
        "description" => "The Righteous Mind: Why Good People are Divided by Politics and Religion is a 2012 social psychology book by the social psychologist Jonathan Haidt, in which the author describes human morality as it relates to politics and religion.",
        "name" => "The Righteous Mind",
        "price" => "$12.18"
      }
    ]
  }
}

```
