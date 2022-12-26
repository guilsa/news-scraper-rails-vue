# Curl test:
# curl \
#   -H "Accept: application/json" \
#   -H "Content-type: application/json" \
#   -X POST \
#   -d ' {"title":"Judge rules against Kari Lake in bid to overturn Arizona election results", "description": "The defeated GOP candidate for Arizona governor claimed that illegal voting and printer malfunctions had cost her the November election", "url": "https://www.washingtonpost.com/politics/2022/12/24/kari-lake-election-lawsuit/"}' \
#   http://127.0.0.1:3000/api/v1/articles/

module Api
  module V1
    class ArticlesController < ApplicationController
      def index
        articles = Article.all
        render json: articles
      end
      
      def show
        article = Article.find(params[:id])
        render json: article
      end
    
      def create
        article_params = params.require(:article).permit(:title, :url, :description)
        article = Article.create(article_params)
        render json: article
      end
    end
  end
end
