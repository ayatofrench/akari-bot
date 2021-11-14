FROM rust:latest as build

# Create a dummy project and build the app's dependencies.
# If the Cargo.toml or Cargo.lock files have not changed,
# we can use the docker build cache and skip these (typically slow) steps.
RUN USER=root cargo new --bin akari-bot
WORKDIR /akari-bot

COPY Cargo.toml Cargo.lock ./

RUN cargo build --release
RUN rm src/*.rs

# Copy the source and build the application.
COPY ./src ./src

RUN rm ./target/release/deps/akari_bot*
RUN cargo build --release

# Copy the statically-linked binary into a scratch container.
FROM debian:buster-slim
COPY --from=build /akari-bot/target/release/akari-bot /usr/src/akari-bot
COPY .env ./.env

CMD ["/usr/src/akari-bot"]
