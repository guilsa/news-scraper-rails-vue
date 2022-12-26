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
