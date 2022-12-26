require 'nokogiri'
require 'open-uri'
require 'date'

module ScraperAdapter
  module Memeorandum
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
        article[:citations] = data.css('.item .mls a').map { |citations| citations.content } # includes all `related` links
        article[:citations_amount] = article[:citations].length
        article[:date] = date
        
        articles << article
      end

      return articles
    end
  end
end