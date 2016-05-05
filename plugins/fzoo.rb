require 'cinch'

class Fzoo
  include Cinch::Plugin

  match /fz(oo+) ?(\S+)?/i, method: :fzoo
  match /bestfzoo/i, method: :bestfzoo
  match /sw(oo+)sh ?(\S+)?/i, method: :swoosh
  match /trace$/i, method: :trace
  match /no$/i, method: :trace
  match /clevelandsteamer$/i, method: :steamer
  match /(?:disapprove|lod)$/i, method: :disapprove
  match /(?:disapprove|disapproveof|lod) (\S+)/i, method: :disapprove_them
  match /h(oo+)ves/i, method: :hooves
  set :help, "\cB!fzoo\cB - Doesn't do anything."

  def initialize(*args)
    super
    @colors = [:black, :blue, :green, :red, :brown, :purple, :orange, :lime, :royal, :pink, :grey]
    info "!fzoo initialized, for what it's worth."
  end

  def bestfzoo(m)
    m.reply "fzoo" + zalgoize("ooooooo <3", 10)
  end

  def fzoo(m, o, them=nil)
    if m.user.to_s.downcase == "fzoo"
      m.reply "You're a fraud, I don't have to play with you!"
      return
    end

    r = rand(1000)
    if r <= 15
      m.reply "fzoo" + zalgoize(o + "ooooo <3", 10)
      return
    elsif r <= 40
      m.reply "fzü <3"
      return
    elsif o.nil?
      extras = ""
    else
      extras = ""
      index = 0
      o.each_char do |char|
        extras << Format(@colors[index], char)
        index = (index + 1) % @colors.length
      end
    end

    if (m.user.to_s.downcase == "hushnowquietnow" and them == nil) or them == "hushnowquietnow"
      extras << " <3 <3"
    end

    if them != nil and m.channel.has_user?(them)
      m.reply "#{them}: fz#{extras} <3"
    else
      m.reply "fz#{extras} <3"
    end
  end

  def swoosh(m, o, them=nil)
    if them != nil and m.channel.has_user?(them)
      prefix = "#{them}: "
    end

    r = rand(1000)
    if r <= 20
      m.reply "#{prefix}sw#{"i" * o.length}sh <3"
    elsif r <= 24
      m.reply "#{prefix}sw#{"å" * o.length}sh <3"
    elsif r <= 25
      m.reply "#{prefix}sw#{"a" * o.length}sh <3"
    elsif r <= 30
      m.reply "#{prefix}sw#{"e" * o.length}sh <3"
    else
      m.reply "#{prefix}sw#{o}sh <3"
    end
  end

  def hooves(m, o)
    if m.user.to_s.downcase.start_with? "gren"
      m.reply "Your hooves are my favorite, Gren. :D"
    else
      m.reply "h#{o}ves <3"
    end
  end

  def trace(m)
    emote = %w{abno ajno ajnopeavi bonno colno darkleno dashno derpno flutno lunano lyrano ppno rarno rlyrano sbno scootno tiano twino twicasualno saynoe}.sample
    m.reply "[](/#{emote})"
  end

  def steamer(m)
    m.reply "You don't REALLY want that, do you?"
  end

  def disapprove(m)
    m.reply "#{m.user}: ಠ_ಠ"
  end

  def disapprove_them(m, them)
    if them == @bot.nick || /^yourself$/i =~ them
      m.reply ":("
    elsif ! m.channel.has_user?( them )
      if /^me$/ =~ them
        m.reply "#{m.user}: ಠ_ಠ"

      elsif /^(any|some)(one|body|pony|pone)$/i =~ them || /^random$/i =~ them # m.channel.users.keys because users is a hash { :username => ["o", "v"] }
        m.reply "#{m.channel.users.keys.sample.to_s}: ಠ_ಠ"

      else
        m.reply "I don't see anyone by that name here."
      end
    else
      m.reply "#{them}: ಠ_ಠ"
    end
  end

  private
  def zalgoize(text, intensity = 50)
    zalgo_chars = (0x0300..0x036F).map{ |i| i.chr('UTF-8') }
    zalgo_chars.concat(["\u0488", "\u0489"])
    source = insert_randoms(text.upcase)
    zalgoized = []
    source.each_char do |letter|
      zalgoized << letter
      zalgo_num = rand(intensity)
      zalgo_num.times { zalgoized << zalgo_chars.sample }
    end
    zalgo_text = zalgoized.join(zalgo_chars.sample)
    return zalgo_text
  end

  def insert_randoms(text)
    random_extras = (0x1D023..0x1D045).map { |i| i.chr('UTF-8') }
    newtext = []
    text.each_char do |char|
      newtext << char
      newtext << random_extras.sample if rand(10) == 1
    end
    return newtext.join
  end
end
