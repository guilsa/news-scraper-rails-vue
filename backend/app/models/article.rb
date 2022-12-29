class Article < ApplicationRecord
  validates :url, uniqueness: true
end
