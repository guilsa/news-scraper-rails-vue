.PHONY: deploy setup

VPS ?= root@racknerd
SITE_ROOT := /var/www/html/news.guilsa.com

# One-time infrastructure setup (creates directories, nginx config)
setup:
	cd ../frontend-infra && ansible-playbook playbooks/deploy.yml

# Deploy static files via rsync
deploy:
	rsync -av --delete \
		--exclude=.git \
		--exclude=node_modules \
		--exclude=frontend-infra \
		dist/ $(VPS):$(SITE_ROOT)/

.DEFAULT_GOAL := deploy
