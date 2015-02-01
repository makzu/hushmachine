require 'cinch'

class Poll
  include Cinch::Plugin

  match /(?:poll|vote)$/, method: :poll
  match /vote (.*)/, method: :vote
  match /results/, method: :results
  match /newpoll/, method: :newpoll

  def initialize(*args)
    super

    @data = YAML.load_file("votes.yaml") rescue {:question => "Should hush set up a real poll?", :writeins => false, :answers => ["yes", "no"], :votes => {}}
  end

  def poll(m)
    m.reply "Current poll: #{@data[:question]} (#{@data[:answers].join "/"}#{@data[:writeins] ? "/write-in" : ""}) Use `!vote <something>` to vote!"
  end

  def vote(m, a)
    m.user.refresh
    unless m.user.authed?
      m.reply "You must register and identify with NickServ to use this command. `/msg nickserv help register` for more details."
      return
    end

    if @data[:votes].keys.include? m.user.authname.downcase
      m.reply "You've already voted!"
    elsif ! (@data[:answers].include? a.downcase or @data[:writeins])
      m.reply "#{a} is not a valid response (no write-ins!)"
    else
      @data[:votes][m.user.authname.downcase] = a.downcase
      File.open("votes.yaml", "w") { |f| f.write @data.to_yaml }
      m.reply "Vote received!"
    end
  end

  def results(m)
    if @data[:votes].count == 0
      m.reply "No votes yet."
      return
    end

    answer = {}
    @data[:answers].each do |x|
      answer[x] = 0
    end

    @data[:votes].each do |x, y|
      answer[y] ||= 0
      answer[y] += 1
    end
    m.reply answer.keys.collect {|x| "#{x}: #{answer[x]}"}.join "; "
  end

  def newpoll(m)
    m.reply "Not yet implemented :D"
  end
end
