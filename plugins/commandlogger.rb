require 'cinch'
require 'date'

class CommandLogger
  include Cinch::Plugin

  match /.*/, method: :execute

  def initialize(*args)
    super

    Dir.mkdir "log" unless Dir.exists? "log"

    info "Command Logger active"
  end

  def execute(m)
    File.open("log/commandlog.#{ Date.today.to_s }.log.gz", "a") do |fz|
      Zlib::GzipWriter.wrap(fz) do |gz|
        gz.puts "#{ Time.now.strftime("%H:%M") }: #{ m.raw }"
      end
    end
  end
end
