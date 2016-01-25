#!/bin/sh
set -e

apk --no-cache add    \
  git                 \
  libffi              \
  libpq               \
  libxml2             \
  libxslt             \
  mariadb             \
  nodejs              \
  postgresql          \
  ruby                \
  ruby-bigdecimal     \
  ruby-bundler        \
  ruby-io-console     \
  ruby-irb

apk --no-cache add --virtual build_deps   \
  build-base                              \
  libffi-dev                              \
  libxml2-dev                             \
  libxslt-dev                             \
  linux-headers                           \
  mariadb-dev                             \
  postgresql-dev                          \
  ruby-dev                                \
  sqlite-dev

  git clone --depth 1 --branch dev https://github.com/opf/openproject.git .

  bundle config build.nokogiri --use-system-libraries
  bundle install --deployment --without development test

  sed -i 's/bower install/bower install --allow-root/g' frontend/package.json
  npm install --unsafe-perm

  SECRET_TOKEN=foobar DATABASE_URL=sqlite3://db/ignore_me.sqlite3 \
    bundle exec rake assets:precompile

  gem install foreman --no-ri --no-rdoc
  sed -i 's/Rails.groups(:opf_plugins)/Rails.groups(:opf_plugins, :docker)/g' \
    config/application.rb

  apk --purge del build_deps
