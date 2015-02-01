require 'cinch'
require_relative 'shushable'

class Hug
  include Cinch::Plugin

  match /hu+gs?$/i, method: :hug_me
  match /hu+gs? (\S+)( \S+)?/i, method: :hug_them
  match /hugcount/i, method: :hugcount

  set :help, "\cB!hug\cB - c'mere you."

  include Shushable
  listen_to :shush, method: :shush
  listen_to :unshush, method: :unshush

  listen_to :bored_hug, method: :bored_hug

  def initialize(*args)
    super

    @yay_hugs = []
    @meh_hugs = []
    @bad_hugs = []

    debug "adding hugs"

    @yay_hugs +=
      [
        "gives %s a great big hug.",
        "tackles and hugs %s.",
        "gives %s a big bear hug!",
        "runs over and hugs %s.",
        "hugs %s, and fireworks go off in the background.",
        "quietly hugs %s.",
        "blushes and hugs %s.",
        "hugs %s warmly.",
        "hugs %s oh so tenderly.",
        "hugs %s.",
        "hugs %s in a style Clark Gable would have admired.",
        "hugs %s, just like a scene from his favorite romance film.",
        "hugs %s, 'cuz hugs are super fun!  Especially when you share them with a good friend.",
        "gives %s a warm platonic hug.",
        "hugs %s over and over.",
        "hugs %s, and is surprisingly warm and soft for a soulless metal automaton.",
        "gives %s a hug while cheesy music swells in the background.",
        "and %s share a tender moment.",
        "robo-hugs %s.  It's like regular hugging, just with more robots.",
        "powers up his hug capacitors and gives %s a hug.",
        "reaches out with his new extend-o-matic arms and hugs %s from across the room.",
        "embraces %s in a warm and friendly hug.",
        "makes an adorable face and hugs %s.",
        "hugs %s for a while, then pulls FineLine in to make it a group hug.",
        "hugs everypony at once, including %s!",
        "gives %s a warm hug and tells them everything will be all right.",
        "tenderly embraces %s.",
        "gives %s a loving hug and a delicious mug of cocoa.",
        "does a happy little dance ending with a warm hug for %s.",
        "hugs %s then runs off giggling.",
        "gives %s a hug and a lollipop.",
        "hugs %s, sorta like this: http://i.imgur.com/tKDr77R.gif",
        "smiles enigmatically and hugs %s.",
        "hugs %s with a big smile on his artificial face!",
        "hugs %s as smooth jazz emits from... somewhere...",
        "sneaks up and gives %s a big hug."
      ]

    @meh_hugs +=
      [
        "hugs %s a little too tightly.",
        "latches onto %s's face.",
        "hugs so hard that %s poops a little.",
        "- more like hugmachine, right? - hugs %s tightly.",
        "gives %s a hug and an ass grab for good measure.",
        "joins %s in a slightly sweaty embrace.",
        "hugs %s, but holds on for far longer than appropriate.",
        "awkwardly one-arm brohugs %s.",
        "hugs %s and squeezes them and calls them George.",
        "hugs %s like it was something he was waiting to do all week!",
        "\"hugs\" %s.  If you know what I mean.",
        "gives %s kind of a weird hug.  Hoverhand city!",
        "feels sort of like a Teddy Ruxpin as he hugs %s.",
        "hugs until %s is blue in the face.",
        "and %s didn't choose the hug life.  The hug life chose them.",
        "hugs %s in a manner that is neither interesting nor dangerous.",
        "gives %s the best hug electrons can buy.",
        "twists his robotic features into a convincing simulacrum of happiness while hugging %s.",
        "gives %s a big beer hug!",
        "gives a quick hug and then runs off before %s knows what hit them.",
        "asks %s to hold very still while he calibrates the orbital hug cannons...",
        "is all out of interesting ways to hug %s, so he does it in a boring way instead.",
        "'s hug servos are on the fritz and lock up while still holding onto %s!  Better get the jaws of life..."
      ]

    @bad_hugs +=
      [
        "hugs %s but is INCREDIBLY uncomfortable.",
        "forgets to vent excess heat before hugging %s, and leaves a few scorch marks.  Whoops...",
        "drags %s into the closet for some \"special\" hugging...",
        "nervously hugs %s but then spaghetti starts POURING out of his pockets and fanny pack.",
        "just kind of stands there like a dead fish while %s hugs him.",
        "hugs %s like a cow hugs an oncoming train.",
        "hugs %s, trembling slightly and breathing heavily into their ear.",
        "holds on to %s for an uncomfortably long time...",
        "hugs %s, just like a scene from his favorite romance.avi.",
        "goes in for a hug, but trips and accidentally headbutts %s.",
        "hesitates a bit too long and hurts %s's feelings.",
        "almost gets %s's sleeves caught in his hug turbines...",
        "!no",
        "http://i.imgur.com/Xd8Ox.jpg",
        "gets just within smelling range of %s. \"Uh, how about a handshake instead?\"",
        "starts a hug, but the motion and squeezing make him queasy and he vomits new posts all down %s's back.",
        "hugs %s and steals their wallet.",
        "leaves some kind of dark, greasy residue on %s after hugging them.",
        "gives %s a hug.  With his mechanical robot claw arms.  What could possibly go wrong?",
        "malfunctions and accidentally hugs %s into a singularity.",
        "hugs %s, but is clearly only doing it because he was told to.",
        "will hug %s for $20, but no less.",
        "is only going to hug somebody like %s for $50 or more.",
        "hugs %s like Mecha-Godzilla would hug Tokyo.",
        "ignores %s entirely and goes over to hug FineLine instead.",
        "starts to hug %s, but crashes before he lets go.  Don't worry, it'll just be a few hours while he reboots...",
        "hugs %s like his idol hugbot: http://pbfcomics.com/115/",
        "leaves a \"kick me\" sign on %s's back after a brief hug.",
        "hugs %s, then secretly writes \"deodorant\" on their shopping list.",
        "hugs %s, tickling them with his mecha-neckbeard.",
        "misinterprets the command as !bug and spends the next ten minutes trying to annoy %s.",
        "hugs %s like a dollar store hooker would."
      ]

    info "!hug initialized with #{ @yay_hugs.length } good hugs, #{ @meh_hugs.length } meh hugs, and #{ @bad_hugs.length } bad hugs."
  end

  def hug_me(m)
    return if m.channel and shushed?

    m.action_reply( all_hugs_sample % m.user.to_s )
  end

  def hug_them(m, them, nicely)
    case nicely
    when /nicely/,/kindly/
      hug = only_good_hugs_sample

    when /mehly/
      hug = only_meh_hugs_sample

    when /meanly/
      hug = only_bad_hugs_sample

    else
      hug = all_hugs_sample

    end

    unless m.channel?
      case them
      when m.user.to_s, /^me$/
        m.action_reply( hug % m.user.to_s )

      else
        m.reply "I don't see #{them} here, #{m.user.to_s}. It's just you and me.."

      end
      return
    end

    return if shushed?

    if m.channel.has_user?( them ) and them != @bot.nick
      m.action_reply( hug % them )
    else
      case them
      when /^me$/i, /^myself$/i
        m.action_reply( hug % m.user.to_s )

      when @bot.nick, /^you(rself)?/i
        m.reply "http://i.imgur.com/AM1bgdg.gif"

      when /^every(one|body|pony|pone)$/i, /^all$/i
        m.reply "http://iambrony.dget.cc/mlp/gif/internethug.gif"

      when /^(any|some)(one|body|pony|pone)$/i, /^random$/i
        # m.channel.users.keys because users is a hash { :username => ["o", "v"] }
        m.action_reply( hug % m.channel.users.keys.sample.to_s )

      else
        m.reply "I don't see anyone by that name here."
      end
    end
  end

  def hugcount(m)
    m.reply "I have #{ Format :bold, @yay_hugs.length.to_s } good hugs, #{ Format :bold, @meh_hugs.length.to_s } meh hugs, and #{ Format :bold, @bad_hugs.length.to_s } bad hugs."
  end

  def bored_hug(m, fineline_only)
    chan = Channel("#reddit-mlpds")

    if fineline_only
      user = "FineLine"
    else
      user = chan.users.sample.to_s
    end

    chan.action( @yay_hugs.sample % user )
  end

  private
  def all_hugs_sample
    ((@yay_hugs * 5) + (@meh_hugs * 3) + (@bad_hugs)).sample
  end

  def only_good_hugs_sample
    ((@yay_hugs * 5) + (@meh_hugs * 2)).sample
  end

  def only_meh_hugs_sample
    @meh_hugs.sample
  end

  def only_bad_hugs_sample
    ((@meh_hugs * 1) + (@bad_hugs * 3)).sample
  end
end
