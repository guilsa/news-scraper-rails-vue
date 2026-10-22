# News Scraper Infrastructure

Ansible playbooks for deploying the News Scraper Rails application infrastructure.

## Prerequisites

- VPS provisioned by `ansible-vps` (Docker, nginx, system basics)
- Ansible installed locally
- SSH access to target VPS

## Deployment

### 1. Deploy Infrastructure (Postgres + Nginx)

```bash
cd infra
ansible-playbook playbooks/deploy.yml
```

This will:
- Create necessary directories
- Deploy rails-postgres container
- Configure nginx for api.guilsa.com

### 2. Deploy Rails Application

After infrastructure is deployed, build and deploy the Rails app:

```bash
cd ../backend
make deploy
```

This will:
- Sync code to VPS
- Build Docker image
- Deploy news-scraper container
- Run database backup
- Restart the application

## Configuration

Variables are defined in `group_vars/production.yml`:

- `rails_postgres_password` - Database password
- `app_domain` - Domain for the API (api.guilsa.com)
- `app_port` - Port the Rails app listens on (3000)
- `news_scraper_api_token` - API authentication token
- `news_scraper_secret_key_base` - Rails secret key base
- `enable_scheduler` - Enable background scraping (true/false)
- `scrape_interval` - How often to scrape (e.g., "3h")

## Architecture

```
/opt/news-scraper/          # Application directory
├── docker-compose.yml      # Container definitions
└── .env                    # Environment variables

/data/rails-postgres/       # Postgres data volume
/opt/backups/news-scraper/  # Database backups
```

Containers:
- `rails-postgres` - PostgreSQL 16 database
- `rails-news-scraper` - Rails application

Network:
- `rails-network` - Private network for Rails app + database

## Testing the Deployment

```bash
# Check containers
ssh root@racknerd "cd /opt/news-scraper && docker compose ps"

# Check logs
ssh root@racknerd "docker logs rails-news-scraper"

# Test API
curl https://api.guilsa.com/api/v1/articles
```

## Health-check deadlines

The Rails probe uses a one-second connection timeout and a two-second total
curl timeout. Postgres uses `pg_isready -t 2`. Both have a five-second Docker
health-check deadline, allowing probes to exit and Docker to collect them.

On RackNerd, probes killed by Docker's deadline left stale exec PID files in
`/run/containerd` until the runtime filesystem filled. An internal timeout
avoids the reproduced failure path while still reporting an unhealthy service.
Keep the Compose and Dockerfile probe definitions aligned.

The article-list endpoint can be slow; investigate its latency separately
and consider a lightweight readiness endpoint. A failed probe must not become
a reason to increase Docker's deadline indefinitely.

After copying this Compose file to `/opt/news-scraper/docker-compose.yml`,
apply these probe-only changes using the existing images:

```bash
ssh racknerd 'cd /opt/news-scraper && docker compose config -q && docker compose up -d --pull never rails-postgres news-scraper'
```

The infrastructure playbook normally pulls Postgres, while `backend/Makefile`
builds a new Rails image. Neither is necessary just to apply these Compose
health-check changes. A future image build includes the updated fallback
Dockerfile probe.
