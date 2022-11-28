# Code With Rails

An opinionated Rails template for starting new Rails projects

Read the [introductory blog post](https://codewithrails.com/rails-docker) about this Rails application template.

---

## Introduction

As Rails developers, we create new Rails projects all the time. Each time, we need to bootstrap and set up the project so that we can reliably and efficiently begin working on them.

One of the major sources of inefficiency is setting up a cross platform Rails development environment.

This Rails template aims to solve that problem by containerizing a Rails application and adding a development environment that works (almost) anywhere Docker works.

## Requirements
- Docker and `docker-compose` (typically installed via Docker Desktop)
- Requires Rails 7.0.x and above

## Initial Installation

Run `rails new your-app --skip-bundle --database=postgresql -m https://raw.githubusercontent.com/Code-With-Rails/rails-template/main/default.rb`

Replace `your-app` with the name of your application.

## Usage

### For booting up the app

Instead of `bin/rails server`, you can run `docker-compose up`

### For entering the shell of the app

Run `docker-compose run app bash`. This will drop you into the container where the app is located.

Note that you should run `docker-compose up` in a separate terminal window so that the database and all related services are booted up already.

## Contributing

Feel free to fork this and create pull requests. We adhere to the Code of Conduct [as described for participation on GitHub](https://docs.github.com/en/site-policy/github-terms/github-event-code-of-conduct). Please be nice to one another.

## License

This code is released under the [MIT License](https://opensource.org/licenses/MIT).
