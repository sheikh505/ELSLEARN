class NewsFeedsController < ApplicationController
  before_filter :set_news_feed, only: [:show, :edit, :update, :destroy]

  respond_to :html
  layout "admin_panel_layout"
  def index
    @news_feeds = NewsFeed.all
    respond_with(@news_feeds)
  end

  def show
    respond_with(@news_feed)
  end

  def new
    @news_feed = NewsFeed.new
    respond_with(@news_feed)
  end

  def edit
  end

  def create
    @news_feed = NewsFeed.new(params[:news_feed])
    @news_feed.save
    respond_with(@news_feed)
  end

  def update
    @news_feed.update_attributes(params[:news_feed])
    respond_with(@news_feed)
  end

  def destroy
    @news_feed.destroy
    respond_with(@news_feed)
  end

  private
    def set_news_feed
      @news_feed = NewsFeed.find(params[:id])
    end
end
