# KafkaExExamples

This repo holds one or more examples of using
[KafkaEx](https://github.com/kafkaex/kafka_ex).

These examples require a local 3-node Kafka cluster on ports 9092, 9093, and
9094.  The provided docker set up makes this possible - you should be able to
run `./scripts/docker_up.sh` and have a cluster running.  The cluster will also
have a zookeeper running on `localhost:2181`.

Compiling should be relatively simple:

```
mix deps.get
mix compile
```

## Consumer Group

First, create a topic and give it 6 partitions:

```
kafka-topics.sh --topic example_topic --zookeeper localhost:2181 --create --partitions 6 --replication-factor 2
```

Then, open three separate terminal windows and set this directory as the working
directory of each.

Run `iex -S mix` in two of the terminals, and `iex -S mix run --no-start` in
the third

In the third terminal, start `KafkaEx` and publish some messages:

```
iex> KafkaEx.start(nil, nil)
iex> Enum.each(0..6, fn(ix) -> KafkaEx.produce("example_topic", ix, "HI #{ix}") end)
```

You should see logs in the other two terminals as the messages are consumed:

```
15:43:41.139 [debug] GOT: %KafkaEx.Protocol.Fetch.Message{attributes: 0, crc: 3062697364, key: "", offset: 26, value: "HI 0"}

15:43:41.139 [debug] GOT: %KafkaEx.Protocol.Fetch.Message{attributes: 0, crc: 3247062274, key: "", offset: 6, value: "HI 1"}

15:43:41.149 [debug] GOT: %KafkaEx.Protocol.Fetch.Message{attributes: 0, crc: 3337091355, key: "", offset: 4, value: "HI 5"}

15:43:46.147 [debug] Committed offset example_topic/1@7 for example_group

15:43:46.170 [debug] Committed offset example_topic/5@5 for example_group

15:43:46.170 [debug] Committed offset example_topic/0@27 for example_group
```

```
15:43:41.136 [debug] GOT: %KafkaEx.Protocol.Fetch.Message{attributes: 0, crc: 797203502, key: "", offset: 4, value: "HI 3"}

15:43:41.142 [debug] GOT: %KafkaEx.Protocol.Fetch.Message{attributes: 0, crc: 2984298893, key: "", offset: 4, value: "HI 4"}

15:43:41.144 [debug] GOT: %KafkaEx.Protocol.Fetch.Message{attributes: 0, crc: 1485008056, key: "", offset: 4, value: "HI 2"}

15:43:46.147 [debug] Committed offset example_topic/3@5 for example_group

15:43:46.170 [debug] Committed offset example_topic/4@5 for example_group

15:43:46.180 [debug] Committed offset example_topic/2@5 for example_group
```

Note that the details of the output may be different in your setup.  Each
consumer should get three messages, one each from three different partitions.

You can then close one of the consumers (Ctrl-G q) and publish more messages.
You should eventually see all 6 messages consumed by the remaining consumer,
though it may take a few seconds for the original consumer to timeout and the
partitions to be reassigned.

You should be able to also re-start the original consumer and repeat this
experiment, keeping in mind that it takes some time after startup for the
topics to be reassigned.
