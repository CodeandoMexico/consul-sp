FROM ruby:2.4.5

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -

# Install essential Linux packages
RUN apt-get update -qq
RUN apt-get install -y build-essential libpq-dev postgresql-client nodejs imagemagick sudo libxss1 libappindicator1 libindicator7 unzip memcached postgis

RUN mkdir /consul
WORKDIR /consul
COPY Gemfile /consul/Gemfile
COPY Gemfile_custom /consul/Gemfile_custom
COPY Gemfile.lock /consul/Gemfile.lock
RUN bundle install
COPY . /consul

# Add a script to be executed every time the container starts.
COPY scripts/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
