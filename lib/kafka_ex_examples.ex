defmodule KafkaExExamples do
  @moduledoc """
  Documentation for KafkaExExamples.
  """

  use Application

  alias KafkaExExamples.Consumer

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(
        KafkaEx.ConsumerGroup.Supervisor,
        [Consumer, "example_group", ["example_topic"]]
      )
    ]
    supervisor_opts = [strategy: :one_for_one]

    Supervisor.start_link(children, supervisor_opts)
  end
end
