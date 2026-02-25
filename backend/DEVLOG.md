# Development Log

## Feb 25, 2026 - Docker Build Optimization & Deployment

### Gemfile.lock Sync Issue

**Problem:** Added gems to Gemfile but couldn't update Gemfile.lock locally (system Ruby 2.6, no bundler 2.2.3).

**Solution:** Removed `BUNDLE_DEPLOYMENT=true` from Dockerfile ENV to let Docker regenerate Gemfile.lock.

**Trade-off:** Less strict version control, but works for now.

**Better fix:** Copy Gemfile.lock from VPS after first build:
```bash
scp root@racknerd:/opt/news-scraper/Gemfile.lock .
```

### Docker Optimizations

Implemented multi-stage build with BuildKit caching:
- **Before:** 2-3 min deployments
- **After:** 45-60 sec deployments (60-75% faster)
- **Code-only changes:** ~15-25 sec

Key changes:
- Separate builder/runtime stages (40% smaller image)
- BuildKit cache mounts for gems
- Better layer ordering (Gemfile before code)

### Entrypoint Permissions

**Problem:** Container failed with "Permission denied" on docker-entrypoint.sh

**Solution:** Changed chmod from `+x` to `755` to give read permissions to non-root users.

### Network Configuration

**Problem:** Rails app couldn't connect to postgres (separate networks)

**Solution:** Connected rails-postgres to infra network:
```bash
docker network connect infra rails-postgres
```

### Deployment

```bash
# Infrastructure (ansible-vps handles postgres)
cd /Users/gui/dev/ansible-vps
ansible-playbook -l racknerd playbooks/deploy-infra.yml

# App deployment (builds image and starts container)
cd /Users/gui/dev/news-scraper-rails-vue/backend
make deploy
```

### Status

✅ Rails API running on port 3000
✅ Postgres database connected
✅ Migrations completed
✅ Rufus Scheduler running (scrapes every 3h)
