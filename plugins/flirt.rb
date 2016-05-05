require 'cinch'

class Flirt
  include Cinch::Plugin

  listen_to :channel, method: :on_channel

  include Shushable
  listen_to :shush, method: :shush
  listen_to :unshush, method: :unshush

  def initialize(*args)
    super
    info "Flirt plugin initialized, you sexy man you"
  end

  def on_channel(m)
    return if shushed?
    return unless m.channel.to_s.match /mlpds$/i and m.user.to_s.match /fineline/i

    case m.to_s
    when /I wish someone would 'special hug' me... :\(/
      sleep 1
      m.reply "..."
      sleep 1
      m.reply "You had your chance at the A.I. Soiree, FineLine!"
    end
  end
end
