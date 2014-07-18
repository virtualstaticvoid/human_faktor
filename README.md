# Employee Leave Management

This is a Rails 3 multi-tenant web application for employee absence management.

<p align="center">
  <img src="public/images/home_page.png?raw=true" alt="Home Page" />
</p>

## Requirements

* MRI Ruby 1.9.3+
* PostgreSQL 8.4+
* [Amazon Web Services](http://aws.amazon.com/) account
* [reCAPTURE](https://www.google.com/recaptcha/admin) account

## Installation

Clone the sources and then install the Gemfile bundle:

```bash
git clone git://github.com/virtualstaticvoid/human_faktor.git
cd human_faktor
bundle install
```

Next, install the `foreman` and `mailcatcher` gems, since they aren't included in the Gemfile bundle:

```bash
gem install foreman
gem install mailcatcher
```

### Configuration

Edit the `.env` file and supply values for at least the following variables:

#### Domain and SMTP

* `DOMAIN_NAME` - The domain name for the application. E.g. example.com.
* `SMTP_DOMAIN` - The domain name for email server. E.g. example.com.

#### reCAPTURE

Sign up on [reCAPTURE](https://www.google.com/recaptcha/admin) (it's free), and create 2 site entries.

* `RECAPTCHA_PUBLIC_KEY` - Public key for your domain for production.
* `RECAPTCHA_PRIVATE_KEY` - Private key for your domain for production.
* `RECAPTCHA_PUBLIC_KEY_DEV` - Public key for `http://0.0.0.0` domain for development.
* `RECAPTCHA_PRIVATE_KEY_DEV` - Private key for `http://0.0.0.0` domain for development.

#### AWS Settings

Sign up on [Amazon Web Services](http://aws.amazon.com/), create an IAM user and S3 bucket.
Ensure that IAM user has write permissions for the S3 bucket.

* `S3_KEY` - AWS Access Key ID.
* `S3_SECRET` - AWS Secret Access Key.
* `S3_BUCKET_NAME` - The S3 bucket name.

Finally, create, migrate and seed the Postgres database:

```bash
bundle exec rake db:create db:migrate db:seed
```

## Usage

Run `foreman start` to start the web server and worker processes.

Open [http://0.0.0.0:3000](http://0.0.0.0:3000) in your browser and login using the user name `admin` and password `p@ssword123`.

Checkout the administration section at [http://0.0.0.0:3000/admin](http://0.0.0.0:3000/admin).

A fully working example can be found at [http://www.human-faktor.com](http://www.human-faktor.com).

## License
MIT Copyright (c) 2011 Chris Stefano
