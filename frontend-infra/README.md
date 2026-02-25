# news.guilsa.com Frontend Infrastructure

Ansible playbooks for setting up news.guilsa.com frontend infrastructure.

## Prerequisites

- VPS provisioned by [ansible-vps](https://github.com/YOUR_USERNAME/ansible-vps) (nginx, system basics)
- Ansible installed locally: `brew install ansible`
- SSH access configured in `~/.ssh/config` for target VPS

## Setup (One-time)

```bash
cd frontend-infra
ansible-playbook playbooks/deploy.yml
```

This creates:
- `/var/www/html/news.guilsa.com` directory
- Nginx configuration for news.guilsa.com

## Deploy Files

```bash
cd ../frontend
npm run build
make deploy
```

Or to a specific VPS:

```bash
make deploy VPS=root@hetzner
```

## Configuration

Variables in `group_vars/production.yml`:
- `site_domain` - Domain name (news.guilsa.com)
- `site_root` - VPS path for site files

## SSH Configuration

Ensure `~/.ssh/config` has:

```
Host racknerd
  HostName YOUR_VPS_IP
  User root
  IdentityFile ~/.ssh/racknerd
```
