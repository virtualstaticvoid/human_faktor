#
# Use `foreman start` to execute this Procfile
#
web: bundle exec thin start -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: bundle exec rake jobs:work
mailcatcher: mailcatcher --http-port 3030 --foreground
