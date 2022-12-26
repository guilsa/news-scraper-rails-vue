# https://guides.rubyonrails.org/active_job_basics.html
# ScrapeMemeorandumJob.perform_later(url: 'https://www.memeorandum.com/')

# todo: have external cron job call api endpoint which invokes this
class ScrapeMemeorandumJob < ApplicationJob
  queue_as :default

  def perform(article)
    begin
      articles = ScraperAdapter::Memeorandum.run
    rescue
      puts "Error scraping Memeorandum"
    end
    article.insert_all(articles)
  end
end
