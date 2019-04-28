defmodule XMLParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :xmlparser,
      version: "0.1.0",
      elixir: "~> 1.0",
      description: "An incredibly fast, pure Elixir XML library",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: [main: "XMLParser"],
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:erlsom, github: "willemdj/erlsom"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :xmlparser,
      files: ~w(lib mix.exs README.md LICENSE VERSION),
      maintainers: ["Krishna"],
      links: %{"GitHub" => "https://github.com/devinus/poison"}
    ]
  end
end
