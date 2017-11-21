defmodule KafkaExExamples do
  @moduledoc """
  Main supervisor module

  This could be your app's main module that has its `Application.start/2`
  callback, or it could be a supervisor implementation inside your project.

  The only part of this that is specific to KafkaEx is the consumer group
  setup within the `start/2` function and the `assign_partitions/2` function
  which could be implemented anywhere.
  """

  defmodule KafkaExExamples.Consumer do
    @moduledoc """
    Main consumer implementation

    This implementsa KafkaEx.GenConsumer.  The only function we need to
    implement is `handle_message_set/2`.
    """

    # this is required
    use KafkaEx.GenConsumer

    # this is not required - I have aliased it for convenience
    alias KafkaEx.Protocol.Fetch.Message

    # this is not generally required, but is required here so that we can
    # log messages
    require Logger

    @doc """
    Main message handling callback function

    Note that we receive multiple messages each time.  Because of the way that
    Kafka works, each request to the broker can provide us with multiple
    messages.

    We return `{:async_commit, consumer_state}` - we do not modify the state
    and we want offsets to be committed asynchronously.  Async commits
    balance safety and performance.
    """
    @spec handle_message_set([Message.t], term) :: {:async_commit, term}
    def handle_message_set(messages, consumer_state) do
      # just loop through each message and print it out
      for  message = %Message{} <- messages do
        Logger.debug(fn -> "GOT: #{inspect message}" end)
      end
      :timer.sleep(300)
      {:async_commit, consumer_state}
    end
  end

  defmodule Producer do
    use GenServer

    @interval_msec 2_000
    require Logger

    def start_link(topic, num_partitions) do
      GenServer.start_link(__MODULE__, {topic, num_partitions}, name: __MODULE__)
    end

    def init({topic, num_partitions}) do
      :timer.send_interval(@interval_msec, :produce)
      {:ok, %{topic: topic, num_partitions: num_partitions, count: 0}}
    end

    def handle_info(:produce, state) do
      partition = :rand.uniform(state.num_partitions) - 1
      from_node = Node.self()
      manager = KafkaEx.ConsumerGroup.get_manager_pid(ExampleConsumerGroup)
      Logger.debug(fn -> 
        inspect Process.info(manager)
      end)
      generation = KafkaEx.ConsumerGroup.generation_id(ExampleConsumerGroup)
      message = "Hello Partition #{partition}, message #{state.count}, " <>
        "from #{inspect from_node}, generation #{generation}"
      Logger.debug(fn -> "Sending '#{message}'" end)
      KafkaEx.produce(state.topic, partition, message)
      {:noreply, %{state | count: state.count + 1}}
    end
  end

  # OTP setup
  use Application

  # aliases for convenience
  alias KafkaEx.ConsumerGroup.PartitionAssignment
  alias KafkaExExamples.Consumer

  require Logger

  # standard OTP Application.start/2 callback
  def start(_type, _args) do
    import Supervisor.Spec

    consumer_group_opts = [
      # commit relatively often to make demonstration easy
      commit_interval: 1_000,
      commit_threshold: 1,
      # same with a relatively quick heartbeat rate
      heartbeat_interval: 1_000,
      # name for process registration
      name: ExampleConsumerGroup,
      # name for the Manager process (for convenience)
      gen_server_opts: [name: ExampleConsumerGroup.Manager],
      # override the partition assignment callback (optional, see below)
      partition_assignment_callback: &assign_partitions/2,
      # how long before Kafka considers a consumer gone
      # must be >= group.min.session.timeout.ms from broker config
      # session_timeout: 6_000
    ]

    # standard OTP supervisor setup
    children = [
      supervisor(
        KafkaEx.ConsumerGroup,
        [Consumer, "example_group", ["example_topic"], consumer_group_opts]
      ),
      worker(Producer, ["example_topic", 6])
    ]
    supervisor_opts = [strategy: :one_for_one]

    Supervisor.start_link(children, supervisor_opts)
  end

  @doc """
  Partition assignment callback

  This is optional.  We choose to override it here so that we can use it as a
  hook to log a message.  This could be used for, e.g., collecting metrics in
  a production system.
  """
  def assign_partitions(members, partitions) do
    # call through to the default KafkaEx partition assignment algorithm
    result = PartitionAssignment.round_robin(members, partitions)

    # log out the assignments for demonstration purposes
    Logger.debug(fn ->
      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n" <>
      "ASSIGN: #{inspect members} | #{inspect partitions} | #{inspect result}"
    end)

    # return the assignment result
    result
  end
end
