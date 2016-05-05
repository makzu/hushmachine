$:.unshift(Dir.pwd)
Process.setproctitle('hushmachine')

# Look at https://github.com/dominikh/Mathetes/blob/cinch_rewrite/bot.rb for some ideas

require 'cinch'
require 'cinch/plugins/identify'
require 'cinch/plugins/basic_ctcp'

require 'yaml'

%w{reconnect convenience bored drawalong help quotes tags fzoo subchecker tell hug shush arttip linkreader flirt commandlogger poll}.each do |plugin|
  require_relative "plugins/#{plugin}"
end

bot = Cinch::Bot.new do
  configure do |c|
    c.load YAML.load_file 'config.yaml'
    #settings = YAML.load_file('config.yaml') || {:plugins => {}}
  end
end

Thread.new do
  bot.start
end

bot.loggers.level = :log
#bot.loggers.level = :debug

while (@cmd = gets) != '/quit\n'
  if @cmd.start_with? '/quit'
    break
  elsif @cmd.start_with? '/me'
    bot.Channel('#reddit-mlpds').action(@cmd[4..-1])
  else
    bot.Channel('#reddit-mlpds').send(@cmd)
  end
end

bot.quit('Killed by console')

sleep 2

exit
