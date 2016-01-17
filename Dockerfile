FROM alpine:3.3
MAINTAINER Linki <linki+docker.com@posteo.de>

ENV RAILS_ENV production

RUN apk --no-cache add    \
      build-base          \
      git                 \
      ruby                \
      ruby-bigdecimal     \
      ruby-bundler        \
      ruby-dev            \
      ruby-io-console     \
      ruby-irb            \
      libffi-dev          \
      libxml2-dev         \
      libxslt-dev         \
      linux-headers       \
      mariadb-dev         \
      nodejs              \
      postgresql-dev      \
      sqlite-dev

WORKDIR /app

RUN git clone --depth 1 --branch v5.0.9 https://github.com/opf/openproject.git .

RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install --deployment --without development test

RUN sed -i 's/bower install/bower install --allow-root/g' frontend/package.json
RUN npm install --unsafe-perm

RUN SECRET_TOKEN=foobar DATABASE_URL=sqlite3://db/ignore_me.sqlite3 \
    bundle exec rake assets:precompile

RUN gem install foreman --no-ri --no-rdoc
RUN sed -i 's/Rails.groups(:opf_plugins)/Rails.groups(:opf_plugins, :docker)/g'\
    config/application.rb

COPY setup_database bin/
COPY entrypoint.sh ./

VOLUME ["/app/files"]
EXPOSE 3000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD HOST=0.0.0.0 PORT=3000 foreman start web
