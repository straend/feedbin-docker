FROM ruby:2.6

ARG FEEDBIN_URL

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libldap-2.4-2 \
    libidn11-dev \
    dnsutils \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/* \
    && gem install idn-ruby -v '0.1.0'

RUN git clone https://github.com/feedbin/feedbin.git /app

RUN gem install bundler -v '2.2.3' \
    && bundle install \
    && bundle exec rake assets:precompile

# Don't limit access to Feedbin to any specific host
# https://github.com/rails/rails/pull/33145
run sed -i 's/ENV\["FEEDBIN_HOST"\]&\.split(",")/nil/g' /app/config/environments/production.rb

# Replace blog links with link to Feedbins official blog
run sed -i 's/href="\/blog/href="https:\/\/feedbin\.com\/blog/g' /app/app/views/settings/settings.html.erb
run sed -i 's/href="\/blog/href="https:\/\/feedbin\.com\/blog/g' /app/app/views/settings/newsletters_pages.html.erb
run sed -i 's/href="\/blog/href="https:\/\/feedbin\.com\/blog/g' /app/app/views/shared/_starred_feed_url.html.erb
run sed -i 's/href="\/blog/href="https:\/\/feedbin\.com\/blog/g' /app/app/views/shared/_settings_nav.html.erb

ENV RAILS_SERVE_STATIC_FILES=true

EXPOSE 3000

