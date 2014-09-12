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
      sleep( 3 )
      @bot.nick = @bot.config.nicks.first
      sleep( 3 )
      Channel("#reddit-mlpds").send "Nobody saw that, right?"
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
