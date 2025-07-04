defmodule TaskValidator.MixProject do
  use Mix.Project

  def project do
    [
      app: :task_validator,
      version: "0.9.5",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "TaskValidator",
      source_url: "https://github.com/ZenHive/task_validator",
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
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      # Code quality tools
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.4", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.22.0", only: :dev}
    ]
  end

  defp description do
    """
    A library for validating Markdown task lists with structured format specifications.
    Features: checkbox subtasks, dependencies, code quality KPIs, task categories,
    multi-project prefixes, and comprehensive error handling documentation.
    """
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE llm.txt),
      maintainers: ["TaskValidator Team"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/ZenHive/task_validator",
        "Docs" => "https://hexdocs.pm/task_validator"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "guides/writing_compliant_tasks.md",
        "guides/sample_tasklist.md",
        "guides/configuration.md"
      ],
      source_url: "https://github.com/ZenHive/task_validator",
      groups_for_extras: [
        Guides: ~r/guides\/[^\/]+\.md/
      ],
      groups_for_modules: [
        Core: [TaskValidator],
        Tasks: [
          Mix.Tasks.ValidateTasklist,
          Mix.Tasks.TaskValidator.CreateTemplate
        ]
      ]
    ]
  end
end
