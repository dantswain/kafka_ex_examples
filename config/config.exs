use Mix.Config

config :kafka_ex,
  brokers: [
    {"localhost", 9092},
    {"localhost", 9093},
    {"localhost", 9094}
  ],
  consumer_group: "kafka_ex",
  disable_default_worker: true,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60,
  use_ssl: true,
  ssl_options: [
    cacertfile: System.cwd() <> "/ssl/ca-cert",
    certfile: System.cwd() <> "/ssl/cert.pem",
    keyfile: System.cwd() <> "/ssl/key.pem"
  ],
  kafka_version: "kayrock"
