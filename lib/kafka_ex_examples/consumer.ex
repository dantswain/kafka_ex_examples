defmodule KafkaExExamples.Consumer do
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message

  require Logger

  def handle_message_set(messages, consumer_state) do
    for  message = %Message{} <- messages do
      Logger.debug(fn -> "GOT: #{inspect message}" end)
    end
    {:async_commit, consumer_state}
  end
end
