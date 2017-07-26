defmodule KafkaExExamples do
  @moduledoc """
  Documentation for KafkaExExamples.
  """

  use Application

  alias KafkaExExamples.Consumer

  def start(_type, _args) do
    import Supervisor.Spec

    consumer_group_opts = [
      commit_interval: 1_000,
      heartbeat_interval: 1_000,
      # must be >= group.min.session.timeout.ms from broker config
      session_timeout: 6_000
    ]

    children = [
      supervisor(
        KafkaEx.ConsumerGroup.Supervisor,
        [Consumer, "example_group", ["example_topic"], consumer_group_opts]
      )
    ]
    supervisor_opts = [strategy: :one_for_one]

    Supervisor.start_link(children, supervisor_opts)
  end
end
