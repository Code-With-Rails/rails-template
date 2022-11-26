# frozen_string_literal: true

# Code With Rails
# (c) Copyright 2022
#
# https://github.com/Code-With-Rails/rails-template
#
# v1.0.0
#
# Intro: A simple, opinionated Rails template to set up your Rails project with a
# Docker development environment.
#
# Installation:
# bin/rails app:template LOCATION=
#
# Usage:
# To run the app - `docker-compose up`
# To go into app's dev shell - 'docker-compose run app bash'
#
# What this template adds:
# - Adds Dockerfile
# - Adds docker-compose.yml with PostgreSQL and Redis services, as well the app service
#
# For more information about Rails template, please refer to the official Rails guide at
# https://guides.rubyonrails.org/rails_application_templates.html.
git :init
git add: '.'
git commit: %( -m 'Initial commit' )

file 'Dockerfile', <<~CODE
  FROM ruby:3.1.2-bullseye

  # Install apt based dependencies required to run Rails as
  # well as RubyGems. As the Ruby image itself is based on a
  # Debian image, we use apt-get to install those.
  RUN apt-get update && apt-get install -y \
    build-essential \
    nano \
    nodejs

  # Configure the main working directory. This is the base
  # directory used in any further RUN, COPY, and ENTRYPOINT
  # commands.
  RUN mkdir -p /app
  WORKDIR /app

  # Copy the Gemfile as well as the Gemfile.lock and install
  # the RubyGems. This is a separate step so the dependencies
  # will be cached unless changes to one of those two files
  # are made.
  COPY Gemfile* ./
  RUN gem install bundler -v 2.3.22 && bundle install --jobs 20 --retry 5

  RUN gem install foreman

  COPY . /app
  RUN rm -rf tmp/*

  ADD . /app
CODE

file 'script/wait-for-tcp.sh', <<~CODE
  #!/usr/bin/env bash
  if [ -z "$2" ]; then cat <<'HELP'; exit; fi
  Usage: script/wait-for-tcp ADDRESS PORT
  Wait for TCP connection at ADDRESS:PORT, retrying every 3 seconds, maximum 20 times.
  HELP

  wait_for_tcp() {
    local addr="$1"
    local port="$2"
    local status="down"
    local counter=0
    local wait_time=3
    local max_retries=20
    while [ "$status" = 'down' -a ${counter} -lt ${max_retries} ]; do
      status="$( (echo > "/dev/tcp/${addr}/${port}") >/dev/null 2>&1 && echo 'up' || echo 'down' )"
      if [ "$status" = 'up' ]; then
        echo "Connection to ${addr}:${port} up"
      else
        echo "Waiting ${wait_time}s for connection to ${addr}:${port}..."
        sleep "$wait_time"
        let counter++
      fi
    done
    if [ ${status} = 'down' ]; then
      echo "Could not connect to ${addr}:${port} after ${max_retries} retries"
      exit 1
    fi
  }

  wait_for_tcp "$1" "$2"
CODE

inside('script') do
  run 'chmod +x wait-for-tcp.sh'
end

file 'script/docker-dev-start-web.sh', <<~CODE
  #!/usr/bin/env bash

  set -xeuo pipefail

  ./script/wait-for-tcp.sh db 5432
  ./script/wait-for-tcp.sh redis 6379

  if [[ -f ./tmp/pids/server.pid ]]; then
    rm ./tmp/pids/server.pid
  fi

  bundle

  if ! [[ -f .db-created ]]; then
    bin/rails db:drop db:create
    touch .db-created
  fi

  bin/rails db:create
  bin/rails db:migrate
  bin/rails db:fixtures:load

  if ! [[ -f .db-seeded ]]; then
    bin/rails db:seed
    touch .db-seeded
  fi

  foreman start -f Procfile.dev
CODE

inside('script') do
  run 'chmod +x docker-dev-start-web.sh'
end

file 'docker-compose.yml', <<~CODE
  version: "3.8"
  networks:
    backend:
    frontend:
    selenium:
  services:
    db:
      image: postgres:14.2-alpine
      ports:
        - "5432:5432"
      environment:
        POSTGRES_USER: postgres
        POSTGRES_PASSWORD: postgres
      networks:
        - backend
    redis:
      image: redis:7-alpine
      ports:
        - "6379:6379"
      networks:
        - backend
    chrome_server:
      image: seleniarm/standalone-chromium
      volumes:
        - /dev/shm:/dev/shm
      networks:
        - selenium
    app:
      build: .
      tty: true
      volumes:
        - .:/app
      working_dir: /app
      environment:
        DB: postgresql
        DB_HOST: db
        DB_PORT: 5432
        DB_USERNAME: postgres
        DB_PASSWORD: postgres
        BUNDLE_GEMFILE: /app/Gemfile
        SELENIUM_REMOTE_URL: http://chrome_server:4444/wd/hub
      command: script/docker-dev-start-web.sh
      networks:
        - backend
        - frontend
        - selenium
      ports:
        - "3000:3000"
      depends_on:
        - db
        - redis
        - chrome_server
CODE

git add: '.'
git commit: '-a -m \'Add Docker config to app\''

# Add .railsrc
file '.railsrc', <<~CODE
rails: --skip-bundle --database=postgresql
CODE

# Update config/database.yml development and test configs
gsub_file 'config/database.yml', /^development:\n  <<: \*default/, <<-CODE
development:
  <<: *default
  username: postgres
  password: postgres
  host: db
CODE

gsub_file 'config/database.yml', /^test:\n  <<: \*default/, <<-CODE
test:
  <<: *default
  username: postgres
  password: postgres
  host: db
CODE

# Update Ruby version in the Gemfile
gsub_file 'Gemfile', /^ruby .*$/, 'ruby \'3.1.2\''
git add: '.'
git commit: '-a -m \'Use Ruby 3.1.2 in the Gemfile\''

# Add Procfile.dev
file 'Procfile.dev', <<~CODE
web: bin/rails server --port 3000 --binding 0.0.0.0
CODE

# Update .gitignore
append_file '.gitignore', '.db-seeded\r\n'
append_file '.gitignore', '.db-created\r\n'
append_file '.gitignore', '.DS_Store\r\n'

puts"""

**********************************

And we're done!

If you have any questions, issue, or suggestions, please go to https://github.com/Code-With-Rails/rails-template to submit an issue.

Next Steps:
1. `cd` into your app directory
2. Run `docker-compose build` to ensure that the container environment builds correctly
3. Run `docker-compose up` to boot up the app
4. To enter into the shell, run `docker-compose run app bash`

Enjoy!

**********************************

"""
