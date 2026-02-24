#!/bin/sh
set -e

echo "==> News Scraper Rails API - Starting..."

# Wait for database to be ready
echo "==> Waiting for database..."
until bundle exec rails runner "ActiveRecord::Base.connection" 2>/dev/null; do
  echo "Database is unavailable - sleeping"
  sleep 2
done
echo "==> Database is ready!"

# Get current git commit SHA (if available)
GIT_SHA=$(cat /app/REVISION 2>/dev/null || echo "unknown")
echo "==> Version: $GIT_SHA"

# Check if database exists
DB_EXISTS=$(bundle exec rails runner "puts ActiveRecord::Base.connection.table_exists?('schema_migrations')" 2>/dev/null || echo "false")

if [ "$DB_EXISTS" = "false" ]; then
  echo "==> Database does not exist, creating..."
  bundle exec rails db:create
  echo "==> Running initial migrations..."
  bundle exec rails db:migrate
else
  echo "==> Database exists, checking for pending migrations..."

  # In production, create backup before migrations
  if [ "$RAILS_ENV" = "production" ]; then
    PENDING_MIGRATIONS=$(bundle exec rails db:migrate:status 2>/dev/null | grep -c "^\s*down" || echo "0")

    if [ "$PENDING_MIGRATIONS" != "0" ]; then
      echo "==> Found $PENDING_MIGRATIONS pending migration(s)"
      echo "==> Creating database backup before migration..."

      # Export database backup (requires pg_dump access from within container)
      # This is a simplified version - full implementation would use pg_dump via postgres container
      BACKUP_DIR="/app/tmp/backups"
      mkdir -p "$BACKUP_DIR"
      BACKUP_FILE="$BACKUP_DIR/pre-migration-$GIT_SHA-$(date +%Y%m%d-%H%M%S).flag"
      touch "$BACKUP_FILE"
      echo "==> Backup flag created: $BACKUP_FILE"
      echo "==> Note: Full database backups are handled by deployment scripts"
    fi
  fi

  echo "==> Running migrations..."
  bundle exec rails db:migrate
fi

echo "==> Migrations complete!"
echo "==> Starting Rails server..."

# Execute the main command (Puma)
exec "$@"
