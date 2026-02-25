APP_NAME := news-scraper
VPS ?= root@racknerd
REMOTE_APP_DIR := /opt/docker-apps/$(APP_NAME)
BACKUP_DIR := /opt/backups/$(APP_NAME)
COMPOSE_FILE := /opt/docker-apps/docker-compose.yml

# Get current git commit SHA
GIT_SHA := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
IMAGE_TAG := $(APP_NAME):$(GIT_SHA)
IMAGE_LATEST := $(APP_NAME):latest

.PHONY: deploy rollback rollback-list rollback-full logs ps health

deploy:
	@echo "🚀 Deploying $(APP_NAME) to $(VPS) (version: $(GIT_SHA))..."
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

	@echo "📦 Step 1/6: Creating remote directories..."
	@ssh $(VPS) "mkdir -p $(REMOTE_APP_DIR) $(BACKUP_DIR)"

	@echo "📁 Step 2/6: Syncing code to VPS..."
	@rsync -avz --delete \
		--exclude .git \
		--exclude .env \
		--exclude tmp \
		--exclude log \
		--exclude node_modules \
		--exclude vendor/bundle \
		./ $(VPS):$(REMOTE_APP_DIR)/

	@echo "📝 Step 3/6: Writing version info..."
	@ssh $(VPS) "echo '$(GIT_SHA)' > $(REMOTE_APP_DIR)/REVISION"

	@echo "💾 Step 4/6: Backing up database..."
	@ssh $(VPS) "cd /opt/infra && docker compose exec -T rails-postgres pg_dump -U newscraper newscraper > $(BACKUP_DIR)/backup-$(GIT_SHA)-\$$(date +%Y%m%d-%H%M%S).sql 2>/dev/null || echo 'Database backup skipped (may not exist yet)'"

	@echo "🔨 Step 5/6: Building Docker image..."
	@ssh $(VPS) "cd $(REMOTE_APP_DIR) && docker build -t $(IMAGE_TAG) -t $(IMAGE_LATEST) ."

	@echo "🔄 Step 6/6: Restarting container..."
	@ssh $(VPS) "cd /opt/docker-apps && docker compose up -d $(APP_NAME)"

	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "✅ Deployment complete!"
	@echo ""
	@echo "📊 Container status:"
	@ssh $(VPS) "docker ps --filter name=$(APP_NAME) --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
	@echo ""
	@echo "🔍 Quick health check (wait 10s for startup)..."
	@sleep 10
	@ssh $(VPS) "curl -s http://localhost:3000/api/v1/articles | head -c 100 || echo '⚠️  API not responding yet, check logs: make logs'"

rollback-list:
	@echo "📜 Available versions for rollback:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@ssh $(VPS) "docker images $(APP_NAME) --format 'table {{.Tag}}\t{{.CreatedAt}}\t{{.Size}}' | head -n 5"
	@echo ""
	@echo "💾 Available database backups:"
	@ssh $(VPS) "ls -lht $(BACKUP_DIR)/ | head -n 5 || echo 'No backups found'"
	@echo ""
	@echo "Usage: make rollback VERSION=<git-sha>"
	@echo "       make rollback-full VERSION=<git-sha>  (includes database restore)"

rollback:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION not specified"; \
		echo "Usage: make rollback VERSION=abc1234"; \
		echo ""; \
		echo "Run 'make rollback-list' to see available versions"; \
		exit 1; \
	fi
	@echo "⏪ Rolling back $(APP_NAME) to version $(VERSION) (app only)..."
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

	@echo "Current version:"
	@ssh $(VPS) "cat $(REMOTE_APP_DIR)/REVISION 2>/dev/null || echo 'unknown'"

	@echo ""
	@echo "🔄 Tagging $(APP_NAME):$(VERSION) as latest..."
	@ssh $(VPS) "docker tag $(APP_NAME):$(VERSION) $(IMAGE_LATEST)"

	@echo "🔄 Restarting container with previous version..."
	@ssh $(VPS) "cd /opt/docker-apps && docker compose up -d $(APP_NAME)"

	@echo ""
	@echo "✅ Rollback complete!"
	@echo "Note: Database was NOT restored. Run 'make rollback-full VERSION=$(VERSION)' to restore database."

rollback-full:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION not specified"; \
		exit 1; \
	fi
	@echo "⚠️  WARNING: This will restore the database and may lose recent data!"
	@echo "Rolling back to version: $(VERSION)"
	@echo ""
	@read -p "Type 'yes' to continue: " confirm; \
	if [ "$$confirm" != "yes" ]; then \
		echo "Rollback cancelled."; \
		exit 1; \
	fi

	@echo "💾 Finding backup for version $(VERSION)..."
	@BACKUP_FILE=$$(ssh $(VPS) "ls -t $(BACKUP_DIR)/backup-$(VERSION)-*.sql 2>/dev/null | head -n1"); \
	if [ -z "$$BACKUP_FILE" ]; then \
		echo "❌ No backup found for version $(VERSION)"; \
		exit 1; \
	fi; \
	echo "Found backup: $$BACKUP_FILE"; \
	echo "🔄 Restoring database..."; \
	ssh $(VPS) "cd /opt/infra && docker compose exec -T rails-postgres psql -U newscraper -d newscraper < $$BACKUP_FILE"

	@echo "🔄 Rolling back application..."
	@$(MAKE) rollback VERSION=$(VERSION)

logs:
	@echo "📋 Showing logs for $(APP_NAME)..."
	@ssh $(VPS) "docker logs -f --tail 100 rails-$(APP_NAME)"

ps:
	@echo "📊 Container status:"
	@ssh $(VPS) "cd /opt/docker-apps && docker compose ps $(APP_NAME)"

health:
	@echo "🏥 Health check for $(APP_NAME)..."
	@ssh $(VPS) "curl -f http://localhost:3000/api/v1/articles && echo '\n✅ API is healthy' || echo '❌ API is not responding'"

.DEFAULT_GOAL := deploy
