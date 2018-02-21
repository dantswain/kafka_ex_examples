use Mix.Config

config :kafka_ex,
  brokers: [
    {"localhost", 9092},
    {"localhost", 9093},
    {"localhost", 9094},
  ],
  consumer_group: "kafka_ex",
  disable_default_worker: false,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60,
  use_ssl: false,
  ssl_options: [ ],
  kafka_version: "0.9.0"

config :logger, level: :debug
