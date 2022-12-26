# ScrapeMemeorandumJob.perform_later(url: 'https://www.memeorandum.com/')

# todo: have external cron job call api endpoint which invokes this
class ScrapeMemeorandumJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "Scraping Memeorandum"
  end
end
