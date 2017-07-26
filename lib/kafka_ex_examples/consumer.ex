defmodule KafkaExExamples.Consumer do
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message

  require Logger

  def handle_message(message = %Message{}, consumer_state) do
    Logger.debug(fn -> "GOT: #{inspect message}" end)
    {:ack, consumer_state}
  end

  def assign_partitions(members, partitions) do
    result = super(members, partitions)
    Logger.debug(fn ->
      "ASSIGN: #{inspect members} | #{inspect partitions} | #{inspect result}"
    end)
    result
  end
end
