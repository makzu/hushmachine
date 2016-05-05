require 'cinch'

class Convenience
  include Cinch::Plugin

  match /reloadplugin (.+)/, method: :reload_plugin

  def initialize(*args)
    super
  end

  def reload_plugin(m, plugin)
    log "!!!!!!!!!!!!!!!!!!!!!!!!! Got a reload_plugin command from #{m.user.authname}"

    unless m.user.authname == "hushnowquietnow"
      m.reply "You're not allowed to do that."
      return
    end

    plugin[0] = plugin[0].capitalize

    begin
      plugin_class = Cinch::Plugins.const_get(plugin)
    rescue NameError
      m.reply "NameError: #{plugin} not found."
      return
    end

    @bot.plugins.select{|p| p.class == plugin_class}.each do |p|
      @bot.plugins.unregister_plugin(p)
    end

    plugin_class.hooks.clear
    plugin_class.matchers.clear
    plugin_class.listeners.clear
    plugin_class.timers.clear
    plugin_class.ctcps.clear
    plugin_class.react_on = :message
    plugin_class.plugin_name = nil
    plugin_class.help = nil
    plugin_class.suffix = nil
    plugin_class.required_options.clear

    # Plugin now 'mostly' unloaded

    file_name = "plugins/#{plugin.downcase}.rb"

    begin
      load(file_name)
      plugin_class = Cinch::Plugins.const_get(plugin)
    rescue NameError
      m.reply "NameError: #{plugin} not found on reload."
      error Exception.to_s
      return
    rescue Exception
      m.reply "Generic Exception: Something bad happened! [](/derpypanic)"
      error Exception.to_s
      return
    end

    @bot.plugins.register_plugin(plugin_class)
    m.reply "Okay."
  end
end
