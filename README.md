# Employee Leave Management

This is a Rails 3 web application for employee absence management.

## Requirements

* MRI Ruby 1.9.3+
* PostgreSQL 8.4+
* AWS account for S3

## Installation

Clone the sources `git clone git://github.com/virtualstaticvoid/human_faktor.git` and then run `cd human_faktor & bundle install`.

Next, run `bundle exec rake db:create db:migrate db:seed` to create, migrate and seed the Postgres database.

## Usage

Run `foreman start` to start the web server and worker processes and open `http://127.0.0.1:3000` in your browser.

Login using `admin` and `p@ssword123`.

A fully working example can be found at [http://www.human-faktor.com](http://www.human-faktor.com)

## License
MIT Copyright (c) 2011 Chris Stefano
