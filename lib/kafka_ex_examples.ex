defmodule KafkaExExamples do
  @moduledoc """
  Documentation for KafkaExExamples.
  """

  use Application

  alias KafkaEx.ConsumerGroup
  alias KafkaEx.ConsumerGroup.PartitionAssignment
  alias KafkaExExamples.Consumer

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    consumer_group_opts = [
      commit_interval: 1_000,
      heartbeat_interval: 1_000,
      name: ExampleConsumerGroup,
      gen_server_opts: [name: ExampleConsumerGroup.Manager],
      partition_assignment_callback: &assign_partitions/2,
      # must be >= group.min.session.timeout.ms from broker config
      session_timeout: 6_000
    ]

    children = [
      supervisor(
        KafkaEx.ConsumerGroup,
        [Consumer, "example_group", ["example_topic"], consumer_group_opts]
      )
    ]
    supervisor_opts = [strategy: :one_for_one]

    Supervisor.start_link(children, supervisor_opts)
  end

  def assign_partitions(members, partitions) do
    result = PartitionAssignment.round_robin(members, partitions)
    Logger.debug(fn ->
      "ASSIGN: #{inspect members} | #{inspect partitions} | #{inspect result}"
    end)
    result
  end
end
