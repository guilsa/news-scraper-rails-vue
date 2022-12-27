namespace :scrape do
  desc "Scrape current articles from memeorandum.com utilizing Nokogiri"
  task memeorandum: :environment do
    ScraperAdapter::Memeorandum.save(Article)
  end

end
