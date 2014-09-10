require 'cinch'

class Reconnect
  include Cinch::Plugin

  listen_to :connect, method: :on_connect
  match /fixnick/i, method: :fixnick

  def initialize(*args)
    super

    info "Reconnect plugin initialized"
  end

  def on_connect(m)
    sleep( 10 )

    # Need to make this more flexible
    unless @bot.nick == @bot.config.nicks.first
      User("Nickserv").send("ghost hushmachine")
      @bot.nick = @bot.config.nicks.first
      Channel("#reddit-mlpds").send "Nobody saw that, right?"
    end

    return

    #fzoo?
    @bot.config.nicks.each do |nickname|
      @bot.nick = nickname

      sleep(5)

      return if @bot.nick == nickname
    end
  end

  def fixnick(m)
    log "!!!!!!!!!!!!!!!!!!!!!!!!! Got a fixnick command from #{m.user.authname}"
    if m.user.authname == "hushnowquietnow"
      on_connect("fzoo")
      m.reply "Okay."
    end
  end

end
