FROM bitwalker/alpine-elixir-phoenix:1.11

RUN wget https://unofficial-builds.nodejs.org/download/release/v14.4.0/node-v14.4.0-linux-x64-musl.tar.xz
RUN tar -xvf node-v14.4.0-linux-x64-musl.tar.xz

WORKDIR /app

COPY mix.exs .
COPY mix.lock .

RUN mix deps.get

RUN mkdir assets

COPY assets/package.json assets
COPY assets/package-lock.json assets

RUN mix deps.compile

CMD source ./.env && \
    mix deps.get && \
    npm install --prefix assets && \
    npm run deploy --prefix assets && \
    mix ecto.create && \
    mix ecto.migrate

RUN mix compile
RUN mix release
