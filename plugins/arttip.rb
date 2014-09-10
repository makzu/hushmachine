require 'cinch'
require_relative 'shushable'

class Arttip
  include Cinch::Plugin

  match /art(?:tip|quote)s? ?(.+)?/i, method: :quote
  match /addart(?:tip|quote)s? (.+)/i, method: :addquote
  set :help, "\cB!arttips\cB - get a random tip\n\cB!addarttip\cB - add a new art tip"

  include Shushable
  listen_to :shush, method: :shush
  listen_to :unshush, method: :unshush

  def initialize(*args)
    super
    @banlist = %w(~fzoo ~hushmachine)
    info "!arttip initialized"
  end

  def quote(m, arg)
    return if shushed?

    if @banlist.include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    quotes = File.readlines("arttipfile")
    unless arg.nil?
      quotes.select! { |q| q.downcase.include? arg.downcase }
    end
    m.reply quotes.sample
  end

  def addquote(m, arg)
    if @banlist.include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless m.channel?
      m.reply "Nope, gotta do that out in the open."
      return
    end
    File.open('arttipfile', 'a') { |f| f << "#{arg}\n" }
    quotes = File.readlines("arttipfile")
    m.reply "Tip added!  There are now #{quotes.length} art tips in my database."
  end
end
