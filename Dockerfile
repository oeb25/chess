FROM marcelocg/phoenix

RUN apt-get update -y && apt-get install inotify-tools build-essential -y

ADD . /code

RUN mix local.hex --force
RUN mix local.rebar --force

CMD ["mix", "do", "ecto.migrate,", "phoenix.server"]
