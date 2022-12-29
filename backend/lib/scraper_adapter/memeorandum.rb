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
      total = 0
      total_with_empty_description = 0
      articles.each do |article|
        # todo: make it faster - it's currently slow, but it works
        article_model.create(article)
        if !article[:description].nil? && article[:description].length > 0
          total_with_empty_description += 1
        end
        total += 1
      end
      puts "Total articles: #{total}"
      puts "Total articles with empty description: #{total_with_empty_description}"
    end

    def self.run
      # https://blog.appsignal.com/2021/01/13/using-mixins-and-modules-in-your-ruby-on-rails-application.html
      doc = Nokogiri::HTML(URI.open('https://www.memeorandum.com/'))

      articles = []

      date = doc.css('.pagecont .rnhang').map(&:content)[0]
      date = date.delete('\n\\').split(', ')[1..2].join(', ')
      date = Date.parse(date).strftime('%Y-%m-%d')

      doc.css('.clus').each do |data|
        article = {}

        article[:title] = data.css('.item .ii a').map(&:content)[0]
        article[:source] = data.css('.item cite a').map(&:content)[0]
        article[:url] = data.css('.ii a').map { |url| url['href'] }[0]
        article[:description] = data.css('.ii').map(&:content)[0]
        citations = data.css('.item .mls a').map { |citations| citations.content } # includes all `related` links
        article[:citations_amount] = citations.length
        article[:date] = date
        
        articles << article
      end

      return articles
    end
  end
end