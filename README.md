# Code With Rails

An opinionated Rails template for starting new Rails projects

---

## Introduction

As Rails developers, we create new Rails projects all the time. Each time, we need to bootstrap and set up the project so that we can reliably and efficiently begin working on them.

One of the major sources of inefficiency is setting up a cross platform Rails development environment.

This Rails template aims to solve that problem by containerizing a Rails application and adding a development environment that works (almost) anywhere Docker works.

## Requirements
- Docker and `docker-compose` (typically installed via Docker Desktop)

## Initial Installation

## Usage

### For booting up the app

Instead of `bin/rails server`, you can run `docker-compose up`

### For entering the shell of the app

Run `docker-compose run app bash`. This will drop you into the container where the app is located.
