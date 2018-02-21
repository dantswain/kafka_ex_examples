defmodule KafkaExExamples.Mixfile do
  use Mix.Project

  def project do
    [app: :kafka_ex_examples,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [mod: {KafkaExExamples, []}, extra_applications: [:logger]]
  end

  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:kafka_ex, path: "../kafka_ex"}
      #  {:kafka_ex, "~> 0.8.0"}
    ]
  end
end
