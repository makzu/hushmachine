require 'cinch'

class Drawalong
  include Cinch::Plugin

  match /(drawalong|da)( help)?$/i, method: :prompt
  match /(?:drawalong|da) new ?(.*)?/i, method: :fresh
  match /(drawalong|da) start/i, method: :start
  match /((drawalong|da) )?join/, method: :join
  match /((drawalong|da) )?(quit|leave|part|unjoin|bail|idontwannadothedrawalonganymore)/i, method: :leave
  match /((drawalong|da) )?continue/i, method: :start
  match /(?:drawalong|da) topic (.*)/i, method: :topic
  match /(drawalong|da) clear/i, method: :clear
  set :help, "Starts a drawalong with a 30-minute timer.  Use \cB!drawalong\cB for more details."

  listen_to :drawalong_expiration_timer, method: :expiry_timer

  def initialize(*args)
    super

    @active = false
    @pending = false
    @participants = []
    @topic = ""
    @last_time = 0

    info "drawalong plugin initialized"
  end

  def prompt(m)
    m.reply "Check your PMs for instructions, #{m.user.to_s}."

    m.user.msg "#{Format(:bold, '!drawalong new <topic (optional)') } - Begin a fresh drawalong with an empty participant list.\n"\
               "#{Format(:bold, '!drawalong topic <topic>') } - Add or change the topic of a drawalong\n"\
               "#{Format(:bold, '!drawalong join')} - Join a drawalong in progress"
    m.user.msg "#{Format(:bold, '!drawalong start')} - Start the drawalong timer\n"\
               "#{Format(:bold, '!drawalong clear')} - Clear out the drawalong list. The list is automatically cleared after 2 hours if nobody keeps the drawalong going.\n"\
               "You can also use #{Format(:bold, "!da")} in place of !drawalong for any command."
  end

  def fresh(m, topic)
    if @active
      m.reply "A drawalong is already running!"
      return
    end

    @pending = true

    @topic = topic
    t = ""
    @participants = []

    unless @topic.strip == ""
      t = " The topic is #{ Format( :green, @topic ) }."
    end

    m.reply "Setting up a fresh drawalong!"\
            "#{ t }"\
            " Use '#{Format(:blue, '!join')}' to join, or '#{Format(:blue, '!drawalong start')}' to begin!"

    @participants << m.user
    m.reply "You're in, #{m.user.to_s}."
    @last_time = Time.now.to_i
  end

  def topic(m, topic)
    @topic = topic
    m.reply "The topic is now #{ Format( :green, @topic ) }."
  end

  def clear(m)
    if @active
      m.reply "I can't clear a drawalong while the timer is running!"
      return
    end

    @pending = false
    @topic = nil
    @participants = []

    m.reply "Cleared. Hope we have another drawalong soon!"
  end

  def join(m)
		if expired? or not @pending
			m.reply "A drawalong hasn't started yet!"
		elsif @participants.include? m.user
      m.reply "You were already in, #{m.user.to_s}!"
    else
      @participants << m.user
      m.reply "You're in, #{m.user.to_s}."
    end
  end

  def leave(m)
    if @participants.include? m.user
      @participants -= [m.user]
      m.reply "You're out, #{ m.user.to_s }."
    end
  end

  def start(m)
    if expired? or not @pending
      m.reply "But there's not a drawalong set up!  Use #{Format(:bold, "!drawalong new")} to start a new one."
      return
    end

    if @active
      m.reply "The drawalong is already going!"
      return
    end

    @active = true

    t = ""

    unless @topic.strip == ""
      t = " The topic is: #{ Format( :green, @topic ) }."
    end

    @end_time = '%02d' % ((Time.now.min + 30) % 60)

    m.reply "Begin!!"\
            "#{ t }"\
            " End time is \cBxx:#{@end_time}\cB!"

    sleep( 20 * 60 )
    m.reply "\cBTen\cB minutes remaining. End time is \cBxx:#{@end_time}\cB!"

    sleep( 5 * 60 )
    m.reply "\cBFIVE\cB minutes remaining. End time is \cBxx:#{@end_time}\cB!"

    sleep( 5 * 60 )
    m.reply "#{@participants.join(" ")} : \cBtime!"

    m.reply "Use #{Format(:blue, '!drawalong continue')} to start the timer for the next round, or #{Format(:blue, '!drawalong clear')} to clear out the list."
    @active = false
    @last_time = Time.now.to_i
  end

  def expirey_timer
    8.times do
      sleep( 15 * 60 )

    end
  end

	def expired?
		( Time.now.to_i - @last_time ) > (2 * 60 * 60 )
	end

end
