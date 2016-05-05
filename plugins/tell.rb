require 'cinch'
require 'json'
require 'human-date'

class Tell
  include Cinch::Plugin

  match /tell (\S+) (.+)/i, method: :tell
  match /reloadtells$/i, method: :check_reload
  listen_to :message, method: :on_message
  #listen_to :join, method: :on_join
  set :help, "\cB!tell\cB <user> <message>"

  def initialize(*args)
    super
    @messages = {}
    @allowed_channels = config[:allowed_channels]
    load_messages
    info "!tell initialized with #{@messages.length} messages"
  end

  def tell(m, target, message)
    if config[:banlist].include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless m.channel? and @allowed_channels.include? m.channel.to_s
      m.reply "Sending tells via PM or from the testing channel is disabled."
      return
    end

    t = target.downcase.gsub(/[:,]/, "")

    if t == "hushmachine"
      m.reply "You don't need to !tell me, #{m.user.to_s}. I'm right here!"
      return
    end

    @messages[t] ||= []
    @messages[t] << { "sender" => m.user.nick, "message" => message, "time" => DateTime.now.to_s }
    save_messages

    m.reply "#{m.user}: I'll pass that along."
  end

  def on_message(m)
    key = m.user.nick.downcase
    return unless @messages.has_key?(key) and m.channel.to_s == "#reddit-mlpds"
    return if m.message.match /^!tell #{m.user.nick.downcase}/i

    @messages[key].each do |msg|
      time = ""
      if msg["time"]
        time = string_ago(msg["time"]) + ": "
      end
      m.reply "#{m.user}, #{time}<#{msg["sender"]}> #{msg["message"]}"
    end

    @messages.delete key
    save_messages
  end

  def check_reload(m)
    log "!!!!!!!!!!!!!!!!!!!!!!!!! Got a checkreload command from #{m.user.authname}"
    if m.user.authname == "hushnowquietnow"
      load_messages
      m.reply "Okay."
    end
  end

  private
  def load_messages
    @messages = JSON.parse File.read('tellfile') rescue {}
  end

  def save_messages
    File.open("tellfile", "w") { |f| f.write JSON.pretty_generate @messages }
  end

  def string_ago(time)
    translator = HumanDate::DateTranslator.new

    before = DateTime.parse(time)
    now = DateTime.now

    if (now.to_time - before.to_time) >= 150000
      translator.parts = [:year, :month, :day]
    elsif (now.to_time - before.to_time) <= 60
      translator.parts = [:year, :month, :day, :hour, :minute, :second]
    else
      translator.parts = [:year, :month, :day, :hour, :minute]
    end

    translator.translate(now, before)
  end
end
