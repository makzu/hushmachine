require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'video_info'

class LinkReader
  include Cinch::Plugin

  listen_to :channel

  set :help, "Currently announcing: deviantart.com, fav.me, vimeo.com, youtube\nBug hush if you think I should announce something else too"

  def initialize(*args)
    super

    info "Linkreader initialized"
  end

  def listen(m)
    uris = URI.extract(m.message)

    response = []

    uris.each do |uri|
      debug "Got a URI: #{uri}"
      if uri.include? "fav.me" or uri.match /deviantart\.com\/.+/
        response << da_response(uri)
      #elsif VideoInfo.usable?(uri)
      #  response << video_response(uri)
      end
    end

    m.reply "#{ m.user.to_s } just linked: #{ array_to_sentence(response) }" unless response.empty?
  rescue OpenURI::HTTPError => e
    m.reply "#{ m.user.to_s }'s link gave an error %s (%s)." % e.io.status
  end

  def da_response(uri)
    if uri.include? "?"
      uri.gsub!(/\?.+$/, '')
    end
    if uri.include? "#"
      uri = "http://fav.me/" + uri.match(/#\/(.+)$/)[1]
    end
    nok = Nokogiri.parse open(uri).read

    #return "" if nok.css('title').inner_text == "deviantART: 404 Not Found"

    response = ""
    if nok.css('#filter-warning').length > 0
      whynsfw = nok.css('#filter-warning small').inner_text.gsub('Contains', 'NSFW for')
      whynsfw = "(NSFW)" if whynsfw == ""
      response += whynsfw + " "
    end

    response += nok.css('title').inner_text.gsub(/\s+/, ' ').strip

    response
  end

  def video_response( uri )
    video = VideoInfo.get( uri )

    "#{ video.title } (#{ number_to_time( video.duration ) })"
  end

  def number_to_time( number )
    out = ""
    if number >= 3600
      out += "#{number / 3600}h "
    end
    if number >= 60
      out += "#{number / 60 % 60}m "
    end
    if number % 60 > 0
      out += "#{number % 60}s"
    end

    out.strip
  end

  def array_to_sentence(ary)
    case ary.length
      when 0
        ""
      when 1
        ary[0].to_s.dup
      when 2
        "#{ary[0]} and #{ary[1]}"
      else
        "#{ary[0..-2].join(", ")}, and #{ary[-1]}"
    end
  end
end
