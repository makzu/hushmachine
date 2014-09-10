require 'cinch'
require_relative 'shushable'

class Quotes
  include Cinch::Plugin

  match /quote(?!count)s? ?(.+)?/i, method: :quote
  match /qts? ?(.+)?/i, method: :qt
  match /s?etouq ?(.+)?/i, method: :etouq
  match /s?tq ?(.+)?/i, method: :tq
  match /addquote (.+)/i, method: :addquote
  match /quotecount ?(.+)?/i, method: :quotecount
  match /myquotecount/i, method: :myquotecount

  #match /grab (\S)+/i, method: :grab
  #listen_to :channel, method: :on_channel

  set :help, "\cB!quote\cB - get a random quote"

  include Shushable
  listen_to :shush, method: :shush
  listen_to :unshush, method: :unshush

  def initialize(*args)
    super
    @banlist = %w(~fzoo ~hushmachine ~oppobot)
    @allowed_channels = ["#reddit-mlpds"]
    info "!quote initialized with #{ File.readlines("quotefile").length} quotes."
  end

  def quote(m, arg)
    return if shushed?

    if @banlist.include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end

    m.safe_reply quotesearch(arg)
  end

  def etouq(m, arg)
    return if shushed? or @banlist.include?(m.user.user.downcase)

    m.safe_reply quotesearch(arg).reverse
  end

  def qt(m, arg)
    return if shushed? or @banlist.include?(m.user.user.downcase)

    m.safe_reply quotesearch(arg).gsub(/[aeiouy]/i, '').gsub(/\s+/, ' ')
  end

  def tq(m, arg)
    return if shushed? or @banlist.include?(m.user.user.downcase)

    m.safe_reply quotesearch(arg).gsub(/[aeiouy]/i, '').gsub(/\s+/, ' ').reverse
  end

  def addquote(m, arg)
    if @banlist.include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless m.channel? and @allowed_channels.include? m.channel.to_s
      m.reply "Nope, gotta do that out in the open."
      return
    end

    File.open('quotefile', 'a') { |f| f << "#{arg}\n" }
    quotes = File.readlines("quotefile")
    m.reply "Quote added!  There are now #{quotes.length} quotes in my database."
  end

  def quotecount(m, arg)
    return if shushed? or @banlist.include?(m.user.user.downcase)

    quotes = File.readlines("quotefile")
    unless arg.nil?
      quotes.select! { |q| q.downcase.include? arg.downcase }
      suffix = " that include #{arg}"
    end
    if quotes.length == 1
      m.safe_reply "There is only one quote in my database#{suffix}."
    elsif quotes.length == 0
      m.safe_reply "There are no quotes in my database#{suffix}."
    elsif quotes.length > 1
      m.safe_reply "There are #{quotes.length} quotes in my database#{suffix}."
    end
  end

  def myquotecount(m)
    quotecount(m, m.user.to_s)
  end

  def grab(m, who)
  end

  def on_channel(m)
  end

  private
  def quotesearch(arg)
    quotes = File.readlines("quotefile")
    if arg.nil?
      return quotes.sample
    elsif arg.match /^#-?\d+/
      index = arg[1..-1].to_i
      if index > quotes.length
        return "I don't have that many quotes yet!"
      else
        return quotes[index - 1] # file starts at #0 remember
      end
    else
      quotes.select! { |q| q.downcase.include? arg.strip.downcase }
      if quotes.count == 0
        return "No quotes found with #{arg}."
      else
        return quotes.sample
      end
    end
  end

end
