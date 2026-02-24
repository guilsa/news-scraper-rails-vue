2026

## Feb 23

*Docker Deployment Infrastructure - Moving from Heroku to Self-Hosted VPS*

After years of this app sitting dormant on Heroku, finally got it deployed to a self-hosted VPS (Hetzner) using Docker. Worked with Claude Code to learn the workflow and build everything systematically.

**What we built:**

1. **Fixed Security Issues:**
   - The hardcoded API token (`FLKWDFJSDFLKJASKLDJ32489`) was a massive blocker listed in the Aug 14, 2025 devlog
   - Moved it to `NEWS_SCRAPER_API_TOKEN` environment variable
   - Added validation to fail gracefully if token isn't configured
   - Generated secure secrets for production (PostgreSQL password, Rails SECRET_KEY_BASE)

2. **Docker Setup:**
   - Created `Dockerfile` with Ruby 3.1.2 Alpine (lightweight!)
   - Built `docker-entrypoint.sh` that automatically runs migrations on deploy
   - Added `.dockerignore` to keep images small
   - Health check uses the `/api/v1/articles` endpoint

3. **Deployment Workflow:**
   - Created `Makefile` with commands: `deploy`, `rollback`, `rollback-full`, `logs`, `health`
   - Every deploy is tagged with git commit SHA (e.g., `news-scraper:00b0171`)
   - Keeps last 3 Docker images for quick rollbacks
   - Database backups happen automatically before migrations
   - Can rollback just the app (fast) or app + database (full restore)

4. **Ruby Version Fix:**
   - `.ruby-version` said 3.0.0 but `Gemfile.lock` was built with 3.1.2
   - Updated `.ruby-version` to 3.1.2 to match reality
   - Docker explicitly uses Ruby 3.1.2 so no ambiguity in production

**Infrastructure (in separate ansible-vps repo):**

The VPS infrastructure lives in `~/dev/ansible-vps` repo. It handles:
- Dedicated PostgreSQL container (`rails-postgres`) just for this app
- Nginx reverse proxy for `api.guilsa.com`
- Docker networking with `infra` network
- Ansible playbooks for infrastructure setup

**Key architectural decision:** Kept deployment config IN this Rails repo, not in the ansible repo. Why?
- Can deploy from anywhere (just need SSH keys)
- No dependency on ansible for daily deploys
- Self-contained: clone this repo → deploy immediately
- Infrastructure repo only needed for one-time VPS setup or infrastructure changes

**The workflow:**

```bash
# Daily deployment (from this repo):
cd backend
make deploy              # Builds, migrates, deploys to Hetzner
make logs                # View container logs
make rollback VERSION=abc1234  # Rollback if needed

# Infrastructure updates (from ansible-vps repo):
ansible-playbook -l hetzner playbooks/orchestrate.yml
```

**Current state:**
- ✅ Deployed to Hetzner VPS at `api.guilsa.com`
- ✅ PostgreSQL running in dedicated container
- ✅ Automated migrations working
- ✅ Scraper tested and working (scraped 23 articles from Memeorandum)
- ✅ API responding correctly: `GET /api/v1/articles`, `POST /api/v1/articles`
- ✅ Rollback system in place (app-only and full)

**Git commits:**
- In this repo: `874191e` (security fix), `00b0171` (Docker setup)
- In ansible-vps repo: `88c31b1` (Rails infra), `b2b47b1` (secrets), `2c325be` (fix)

**What's NOT done (future work):**
- SSL/HTTPS: Currently relying on Cloudflare → nginx (HTTP locally)
- Background jobs: Using Active Job `:async` (in-memory). Could add Sidekiq + Redis later for persistence
- Error tracking: Not yet connected to GlitchTip (easy to add when needed)
- Scheduled scraping: No cron job yet, have to trigger via API

**Lessons learned working with Claude Code:**
- Ask questions BEFORE building (we did "Option C" planning)
- Keep repos separate with clear boundaries (app vs infrastructure)
- Use background agents to explore while planning
- Systematic commits in the right repo for each change
- Self-contained deployment >> complex dependencies

**Why this approach rocks for active development:**
- Deploy multiple times per day with one command
- Rollback in 3 seconds if something breaks
- Database backups automatic (safety net)
- Git SHA tagging means you always know what's deployed
- Can test locally with Docker if needed

Next time I touch this: Just run `make deploy` from backend directory. That's it.

---

2025

## Aug 14

*Review repo, understand how /backend works*

BLOCKER:
- In articles_controller.rb there is sensitive data that CANNOT be added to version control.

Files containing sensitive information:
- app/controllers/api/v1/articles_controller.rb
- backend/config/master.key
- backend/config/credentials.yml.enc


## Aug 14

*Picking this back up from Thu Jan 5 00:09:30 2023.*

Purpose: Mainly history. Can be deleted otherwise.

Current state of the repo as it was left is:

```bash
➜  news-scraper-rails-vue git:(frontend-stage-1) ✗ gst
On branch frontend-stage-1
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        backend/lib/scraper_adapter/google_books.rb
        frontend/
```

Note I am in a `frontend-stage-1` branch.

*Questions:*
- Why is the frontend folder not yet added to version control? For one, it makes sense this was the scope of what I was working on, thus the branch name. So then the new question becomes why was I including a `backend/lib/scraper_adapter/google_books.rb` along with this? Perhaps the answer to this is that the backend repo was all the scraping (as a Rails worker in a Pi) and API service logic (in Heroku). I remember having that working. And never having a frontend for that, which is fine (all attention was going to understanding Rails, Rails delayed jobs, and a web API service really well). This actually checks. Looking inside the frontend folder, it's a brand new Vue scaffold. So IN CONCLUSION: the frontend changes is safe to trash and I can pick this up at any time. As per the backend/lib/scraper_adapter/google_books.rb logic, I remember getting side-tracked because I made a huge list of Pulitzer prize history books.

*What google_books.rb is:*
- Takes a non-clean list of book titles, without author, and calls Google Books API once per book, to try to get page count, author, date, and author gender. For every call, it updates a progress bar (plaintext). 
	- My reco: save the book list somewhere else (google spreadsheet), and trash the google_books.rb file. Or keep in a `google books scrape adapter` branch.

*In conslusion how I am proceeding:*
1. Add `/docs/DEVLOG.md` (these notes) to main branch
2. Trash the frontend folder. Not needed for now. Nothing important there.
3. Create and push new branch remote (`curated-books-data-enrichment`). Include backend/lib/scraper_adapter/google_books.rb.
4. Delete `frontend-stage-1` branch. No longer needed.