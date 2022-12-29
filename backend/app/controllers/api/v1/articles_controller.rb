# Curl create v1:
# curl \
#   -H "Accept: application/json" \
#   -H "Content-type: application/json" \
#   -H "Authorization: FLKWDFJSDFLKJASKLDJ32489" \
#   -X POST \
#   -d ' {"title":"title", "source": "NUT", "url": "https://www.washingtonpost.com/politics/2022/12/24/kari-lake-election-lawsuit/", "description": "desc", "citations_amount": "44", "date": "2022-03-22"}' \
#     https://news-scraper-rails-vue.herokuapp.com/api/v1/articles
  # http://127.0.0.1:3000/api/v1/articles/
# Curl create v2 (with job):
# curl \
#   -H "Accept: application/json" \
#   -H "Content-type: application/json" \
#   -H "Authorization: FLKWDFJSDFLKJASKLDJ32489" \
#   -X POST \
#     http://127.0.0.1:3000/api/v1/articles
#     https://news-scraper-rails-vue.herokuapp.com/api/v1/articles

module Api
  module V1
    class ArticlesController < ApplicationController

      before_action :is_protected, only: :create

      def index
        articles = Article.all
        render json: articles
      end
      
      def show
        article = Article.find(params[:id])
        render json: article
      end
    
      def create
        # article_params = params.require(:article).permit(
        #   :title, :source, :url, :description, :citations_amount, :date
        # )
        # article = Article.create(article_params)
        # render json: article
        ScrapeMemeorandumJob.perform_later(Article)
        
        # return only 200
        render nothing: true, status: 200
      end

      private
        def is_protected
          if request.headers["Authorization"] != 'FLKWDFJSDFLKJASKLDJ32489'
            render json: { error: 'Not Authorized' }, status: :unauthorized
          end
        end
    end
  end
end
