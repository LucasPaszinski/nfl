FROM elixir:latest

RUN apt-get update
RUN apt-get install -y postgresql-client
RUN apt-get install -y inotify-tools
RUN apt-get install -y nodejs
RUN curl -L https://npmjs.org/install.sh | sh
RUN mix local.hex --force
RUN mix archive.install hex phx_new 1.5.4 --force
RUN mix local.rebar --force 
RUN mix deps.get 
RUN mix setup

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN mix ecto.create
RUN mix ecto.migrate
RUN mix run app/priv/repo/seeds.exs

CMD ["mix", "phx.server"]
