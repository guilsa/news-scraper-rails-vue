FROM ruby:3.1.2-alpine

# Install dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    curl

WORKDIR /app

# Install bundler
RUN gem install bundler:2.3.26

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test --jobs 4 --retry 3

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S rails && \
    adduser -S rails -u 1001 -G rails && \
    chown -R rails:rails /app

# Create necessary directories
RUN mkdir -p tmp/pids tmp/sockets log && \
    chown -R rails:rails tmp log

USER rails

# Environment variables
ENV RAILS_ENV=production
ENV PORT=3000
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

EXPOSE 3000

# Copy and set entrypoint
COPY --chown=rails:rails docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://127.0.0.1:3000/api/v1/articles || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
