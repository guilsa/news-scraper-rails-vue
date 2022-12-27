# https://guides.rubyonrails.org/active_job_basics.html
# ScrapeMemeorandumJob.perform_later()

# todo: have external cron job call api endpoint which invokes this
class ScrapeMemeorandumJob < ApplicationJob
  queue_as :default

  def perform(article_model)
    ScraperAdapter::Memeorandum.save(article_model)
  end
end
