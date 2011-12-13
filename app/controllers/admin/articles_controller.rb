class Admin::ArticlesController < AdminBaseController

  load_and_authorize_resource :article_collection
  load_and_authorize_resource :article, :through => :article_collection

  respond_to :html, :xml, :json

  #/admin/article_collections/1/articles
  def index
    @articles = @article_collection.articles.asc(:created_at).page(params[:page])
    respond_with(:admin, @article_collection, @articles)
  end

  #/admin/article_collections/1/articles/new
  def new
    respond_with(:admin, @article_collection, @articles)
  end


end
