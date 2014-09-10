require 'cinch'

class Bored
  include Cinch::Plugin

  timer 2500, method: :bored
  match /chatspeed$/i, method: :chatspeed
  listen_to :channel, method: :on_channel

  def initialize(*args)
    super

    @message_times = []
    update_buffer
    @debug_bored = false
    info "Bored plugin initialized!  But that's not very interesting."
  end

  def on_channel(m)
    return unless m.channel.to_s.match /mlpds$/i

    # FineLine's messages don't count against the 'bored' timer
    if m.user.to_s.match /fineline/i
      return
    end

    update_buffer
  end

  def chatspeed(m)
    bored_time = Time.now - @message_times.first
    m.reply "#{ bored_time.round }"
  end

  def bored
    bored_time = Time.now - @message_times.first

    if bored_time >= 3000
      bored_switch = Random.rand( 100 )
      info "I'm #{ bored_time } bored, let's do something on number #{ bored_switch }"

      case bored_switch
      when 0..7
        Channel("#reddit-mlpds").action "awkwardly tries to flirt with FineLine. #{ Format( :black, "\"So, uh.. you come here often?\"" ) }"
        update_buffer

        Channel("#reddit-mlpds-bots").send "b: option 1" if @debug_bored
      when 8..14
        Channel("#reddit-mlpds").action "awkwardly tries to flirt with FineLine. #{ Format( :black, "\"Wanna see my collection of 0s and 1s?\"" ) }"
        update_buffer

        Channel("#reddit-mlpds-bots").send "b: option 2" if @debug_bored
      when 15..21
        Channel("#reddit-mlpds").action "awkwardly tries to flirt with FineLine. #{ Format( :black, "\"I've got the RAID array if you have the SCSI port, baby.\"" ) }"
        update_buffer
      when 22..35

        # 'true' in :bored_hug maps to 'fineline only'
        @bot.handlers.dispatch(:bored_hug, nil, true)
        update_buffer

        Channel("#reddit-mlpds-bots").send "b: option 3" if @debug_bored
      when 36..45
        @bot.handlers.dispatch(:bored_hug, nil, false)
        update_buffer

        Channel("#reddit-mlpds-bots").send "b: option 4" if @debug_bored
      end
    end
  end

  private
  def update_buffer
    @message_times.push Time.now
    if @message_times.length > 15
      @message_times.shift
    end
  end
end
