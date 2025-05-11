defmodule TaskValidator.MixProject do
  use Mix.Project

  def project do
    [
      app: :task_validator,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "TaskValidator",
      source_url: "https://github.com/zen-hiv/task_validator",
      docs: docs()
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
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A library for validating Markdown task lists against a structured format specification.
    Ensures consistent task tracking with proper ID formats, required sections, and status values.
    """
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      maintainers: ["TaskValidator Team"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/zen-hiv/task_validator",
        "Docs" => "https://hexdocs.pm/task_validator"
      }
    ]
  end

  defp docs do
    [
      main: "TaskValidator",
      extras: ["README.md"]
    ]
  end
end
