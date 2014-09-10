require 'cinch'

class Stats
  include Cinch::Plugin

  #match /stats/i

  def execute(m)
    m.reply "http://scootaloo.com/stats/reddit-mlpds"
  end
end

