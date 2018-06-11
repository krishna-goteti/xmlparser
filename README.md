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
