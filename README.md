# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

## OSX Dev setup

Install Homebrew if you don't already have it

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

Install postgresql if you don't have it

- `brew install postgresql`
- `brew services start postgresql`

Install ImageMagick so that you can install RMagick.
If you're on OSX Sierra, you'll need to force an older version of ImageMagick

- `brew install imagemagick@6`
- `brew link --force imagemagick@6`

Install all the project's dependencies with `bundle install`

## First time configuration

Create your development database

`bundle exec rake db:setup`
