require 'nokogiri'
require 'open-uri'
require 'date'

module ScraperAdapter
  module Memeorandum
    def self.save(article_model)
      begin
        articles = ScraperAdapter::Memeorandum.run
      rescue
        puts "Error scraping Memeorandum"
      end
      articles.sort_by! { |article| article[:citations_amount] }.reverse!
      article_model.insert_all(articles)
    end

    def self.run
      # https://blog.appsignal.com/2021/01/13/using-mixins-and-modules-in-your-ruby-on-rails-application.html
      doc = Nokogiri::HTML(URI.open('https://www.memeorandum.com/'))

      articles = []

      doc.css('.clus').each do |data|
        article = {}

        article[:title] = data.css('.item .ii a').map(&:content)[0]
        article[:source] = data.css('.item cite a').map(&:content)[0]
        article[:url] = data.css('.ii a').map { |url| url['href'] }[0]
        article[:description] = data.css('.ii').map(&:content)[0]
        citations = data.css('.item .mls a').map { |citations| citations.content } # includes all `related` links
        article[:citations_amount] = citations.length
        article[:date] = Date.today.strftime('%Y-%m-%d')

        articles << article
      end

      return articles
    end
  end
end