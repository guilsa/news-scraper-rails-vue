require 'rufus-scheduler'

# Only run scheduler if explicitly enabled (production default: true)
scheduler_enabled = ENV.fetch('ENABLE_SCHEDULER', Rails.env.production? ? 'true' : 'false')

if scheduler_enabled == 'true'
  # Get scraping interval from ENV (default: 3 hours)
  scrape_interval = ENV.fetch('SCRAPE_INTERVAL', '3h')

  Rails.logger.info "==> Rufus Scheduler: Initializing..."
  Rails.logger.info "    Scrape interval: #{scrape_interval}"

  scheduler = Rufus::Scheduler.new

  # Schedule periodic scraping
  scheduler.every scrape_interval, first_in: '30s' do
    Rails.logger.info "Scheduler: Triggering Memeorandum scrape (interval: #{scrape_interval})"

    begin
      ScrapeMemeorandumJob.perform_later(Article)
      Rails.logger.info "Scheduler: Scrape job queued successfully"
    rescue => e
      Rails.logger.error "Scheduler: Failed to queue scrape job - #{e.message}"
    end
  end

  Rails.logger.info "==> Rufus Scheduler: Started successfully"
  Rails.logger.info "    First scrape will run in 30 seconds, then every #{scrape_interval}"
else
  Rails.logger.info "==> Rufus Scheduler: Disabled (ENABLE_SCHEDULER=#{scheduler_enabled})"
end
