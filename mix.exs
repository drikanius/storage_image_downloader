defmodule StorageImageDownloader.MixProject do
  use Mix.Project

  @app :storage_image_downloader
  @name "StorageImageDownloader"
  @description "A simple solution to download images from storage"
  @version "0.1.2"
  @github "https://github.com/drikanius/#{@app}"
  @author "Jeferson Vieira Ramos"
  @license "MIT"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.18",
      name: @name,
      description: @description,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env()
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
      {:ex_doc, "~> 0.29", only: [:dev, :docs], runtime: false},
      {:excoveralls, "~> 0.16", only: [:dev, :test], runtime: false},
      {:req, "~> 0.5.10"}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @github,
      extras: [
        "README.md"
      ]
    ]
  end

  defp package do
    [
      name: @app,
      maintainers: [@author],
      licenses: [@license],
      links: %{"Github" => @github}
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end
end
