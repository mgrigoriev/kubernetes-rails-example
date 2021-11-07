# Run to build:
#   docker build --no-cache -t mgrigoriev/kubernetes-rails-example:main .
#   docker push mgrigoriev/kubernetes-rails-example:main

# ————————————————————————————————————————————————————————————————————————————————
# Stage 1: Builder
FROM ruby:2.7.4-alpine as Builder

ENV APP_HOME=/rails_app

WORKDIR $APP_HOME

# Add basic packages
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    git \
    nodejs \
    yarn \
    tzdata \
    file

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config --local frozen 1 && \
    bundle config --local without 'development test' && \
    bundle install --jobs 4 --retry 3 && \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete

# Copy the whole application folder into the image
COPY . ./

# Install Node modules
COPY package.json yarn.lock ./
RUN yarn install --production --frozen-lockfile

# Precompile assets (managed by sprockets and webpack)
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Remove folders not needed in resulting image
# RUN rm -rf node_modules tmp/cache app/assets vendor/assets lib/assets spec
RUN rm -rf node_modules tmp/cache spec

# ————————————————————————————————————————————————————————————————————————————————
# Stage 2: Final
FROM ruby:2.7.4-alpine

ENV APP_HOME=/rails_app

WORKDIR $APP_HOME

# Install packages
RUN apk add --update --no-cache \
    tzdata \
    postgresql-client \
    netcat-openbsd \
    bash \
    rsync

# Add user
RUN addgroup -g 1000 -S app \
 && adduser -u 1000 -S app -G app

USER app

# Copy app with gems from Builder stage
COPY --from=Builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=Builder --chown=app:app $APP_HOME ./

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
