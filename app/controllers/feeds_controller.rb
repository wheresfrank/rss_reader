class FeedsController < ApplicationController
  before_action :set_feed, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /feeds or /feeds.json
  def index
    @feeds = current_user.feeds
    @articles = @feeds.flat_map do |feed|
      parser = RssFeedParser.new(feed)
      articles = parser.extract_articles
      
      articles if articles.present?
    end.compact
    
    @articles.sort_by! { |article| -DateTime.parse(article[:pub_date]).to_i }
  end

  # GET /feeds/1 or /feeds/1.json
  def show
    parser = RssFeedParser.new(@feed)
    @articles = parser.extract_articles
    @articles.sort_by! { |article| -DateTime.parse(article[:pub_date]).to_i } if @articles.present?
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
  end

  # POST /feeds or /feeds.json
  def create
    @feed = current_user.feeds.build(feed_params)
    validate_feed_source(@feed)

    respond_to do |format|
      if @feed.errors.empty? && @feed.save
        format.html { redirect_to feeds_url, notice: "Feed was successfully created." }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feeds/1 or /feeds/1.json
  def update
    # Create a temporary feed object with the new params to validate before updating
    temp_feed = Feed.new(feed_params)
    temp_feed.id = @feed.id
    validate_feed_source(temp_feed)

    respond_to do |format|
      if @feed.errors.empty? && @feed.update(feed_params)
        format.html { redirect_to feeds_url, notice: "Feed was successfully updated." }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1 or /feeds/1.json
  def destroy
    @feed.destroy!

    respond_to do |format|
      format.html { redirect_to feeds_url, notice: "Feed was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_feed
    @feed = Feed.find(params[:id])
  end

  # Validate the source of the feed is valid
  def validate_feed_source(feed)
    begin
      parser = RssFeedParser.new(feed)
      articles = parser.extract_articles

      if articles.empty?
        raise "Unable to extract articles from the feed."
      end

    rescue => e
      feed.errors.add(:source, "is invalid or unreachable: #{e.message}")
    end
  end

  # Extract arcles from RSS Feeds
  def extract_articles
    articles = []

    @doc.xpath('//rss/channel/item').each do |item|
      article = {
        title: item.at_xpath('title')&.text,
        link: item.at_xpath('link')&.text,
        description: item.at_xpath('description')&.text,
        pub_date: item.at_xpath('pubDate')&.text,
        image: item.at_xpath('image')&.text
      }

      articles << article
    end

    articles
  end

  # Only allow a list of trusted parameters through.
  def feed_params
    params.require(:feed).permit(:name, :source, :favorite, :user_id)
  end
end
