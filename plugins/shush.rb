require 'cinch'

class Shush
  include Cinch::Plugin

  match /s?hush/i, method: :shush
  set :help, "\cB!hush\cB/\cB!shush\cB - Stop all non-essential messages for a while.  Only usable by some users."
  
  def initialize(*args)
    super

    @shushed = false
    info "!shush enabled for #{config[:shushers].length} users"
  end

  def shush(m)
    # Only let ops, half-ops, and whitelisted users to shush hushmachine
    unless config[:shushers].include?(m.user.authname.downcase) or m.channel.opped?(m.user) or m.channel.half_opped?(m.user)
      return
    end

    unless @shushed
      duration = 90 + rand(121)
      @bot.handlers.dispatch(:shush)
      m.reply "Shutting up for a bit."
      sleep(duration)
      @bot.handlers.dispatch(:unshush)
    end
  end

  def can_shush?(user)

  end
end
