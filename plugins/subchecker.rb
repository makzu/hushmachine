require 'cinch'
require 'snoo'

class SubChecker
  include Cinch::Plugin

  set :help, "I'll announce new posts as they come into our sub, usually less than a minute after they're posted."

  def initialize(*args)
    super
    @super_debug = true
    @reddit = Snoo::Client.new({:useragent => "Hushmachine IRC bot by /u/hushnowquietnow, using Snoo ruby API wrapper"})
    listings = fetch_listings

    @already_checked = listings.map { |post| post["data"]["id"] }
    info "Subchecker initialized"
  end

  timer 60, method: :check

  def check
    listings = fetch_listings

    debug "Checking sub.  Got ids: " + listings.map { |post| post["data"]["id"] }.to_s

    listings.delete_if { |post| @already_checked.include? post["data"]["id"] }

    if listings.length > 3
      Channel("#reddit-mlpds-bots").send "I dunno what's up with Reddit, but I don't want to 'new post' flood any more."
      return
    end

    listings.each do |post|
      posttitle = post["data"]["title"]
      posttitle.gsub!("\n", ' ')
      posttitle.gsub!(/[\x00-\x1f]/, '')
      posttitle.gsub!(/\s+/, ' ')

      message = "New"\
                "#{post['data']['over_18'] ? Format(:bold, Format(:red, ' [NSFW]')) : ''}"\
                " post by #{Format(:blue, post['data']['author'])}"\
                " at http://redd.it/#{post['data']['id']} - \"#{Format(:blue, posttitle)}\""

      Channel("#reddit-mlpds").send message

      @already_checked.push post["data"]["id"]

      if @already_checked.length > 100
        @already_checked.shift
      end
    end

  end

  private
  def fetch_listings
    @reddit.get_listing({:subreddit => "MLPDrawingSchool",
                         :page => "new",
                         :sort => "new",
                         :limit => 25})["data"]["children"]
  end
end
