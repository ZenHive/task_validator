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
      source_url: "https://github.com/yourusername/task_validator"
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
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
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
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/yourusername/task_validator"}
    ]
  end
end
