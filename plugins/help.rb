require 'cinch'

class Help
  include Cinch::Plugin

  match /help$/i, method: :help
  set :help, "\cB!help\cB - Whoa, this is a bit too meta for me"

  def initialize(*args)
    super
    info "!help initialized"
  end

  def help(m)
    m.reply "I have help for: arttip fzoo help hug linkreader quotes shush subchecker tags tell\nUse \cB!help <command>\cB for more info."
  end
end
