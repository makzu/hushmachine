$:.unshift(Dir.pwd)

# Look at https://github.com/dominikh/Mathetes/blob/cinch_rewrite/bot.rb for some ideas

require 'cinch'
require 'cinch/plugins/identify'
require 'cinch/plugins/basic_ctcp'

require 'yaml'

%w{reconnect convenience bored drawalong help quotes tags fzoo subchecker tell hug shush arttip linkreader flirt commandlogger}.each do |plugin|
  require "plugins/#{plugin}"
end

bot = Cinch::Bot.new do
  configure do |c|
    settings = YAML.load_file('config.yaml') || {:plugins => {}}

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
                          CommandLogger,
                          Drawalong,
                          Fzoo,
                          Flirt,
                          Help,
                          Hug,
                          LinkReader,
                          Quotes,
                          Reconnect,
                          Shush,
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
