$:.unshift(Dir.pwd)

require 'cinch'
require 'cinch/plugins/identify'
require 'cinch/plugins/basic_ctcp'

require 'yaml'

%w{reconnect convenience bored drawalong help quotes tags fzoo subchecker tell stats hug shush arttip linkreader flirt}.each do |plugin|
  require "plugins/#{plugin}"
end

bot = Cinch::Bot.new do
  configure do |c|
    settings = YAML.load_file('config.yaml') || {}

    # Eventually all (or at least most) settings will be in the file rather
    # than being specified here
    c.server = "irc.freenode.net"
    c.channels = ["#reddit-mlpds", "#reddit-mlpds-spoilers", "#reddit-mlpds-bots"]
    c.nicks = ["hushmachine", "FineLineFan", "hushmachinemk2", "hushrobot"]
    c.realname = "mk2"
    c.user = "mk2"
    c.plugins.plugins = [
                          Cinch::Plugins::BasicCTCP,
                          Cinch::Plugins::Identify,

                          Arttip,
                          Bored,
                          Convenience,
                          Drawalong,
                          Fzoo,
                          Flirt,
                          Help,
                          Hug,
                          LinkReader,
                          Quotes,
                          Reconnect,
                          Shush,
                          Stats,
                          SubChecker,
                          Tags,
                          Tell
                        ]

    settings[:plugins].each do |plugin, options|
      c.plugins.options[plugin] = options
    end
  end
end

Thread.new do
  bot.start
end

bot.loggers.level = :log
#bot.loggers.level = :debug

while (@cmd = gets) != "/quit\n"
  break if @cmd == "/quit"
  if @cmd.start_with? "/me"
    bot.Channel("#reddit-mlpds").action(@cmd[4..-1])
  else
    bot.Channel("#reddit-mlpds").send(@cmd)
  end
end

bot.quit("Killed by console")

sleep 2

exit
