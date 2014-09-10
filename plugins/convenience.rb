require 'cinch'

class Convenience
  include Cinch::Plugin

  match /toggledevoice/, method: :toggle_devoice
  match /reloadplugin (.+)/, method: :reload_plugin
  listen_to :voice, method: :on_voice

  def initialize(*args)
    super
    @do_devoice = true
  end

  def toggle_devoice(m)
    if m.user.to_s == "hushnowquietnow"
      if @do_devoice
        @do_devoice = false
      else
        @do_devoice = true
      end
    end
  end

  def on_voice(m, user)
    if user.to_s == "hushnowquietnow" and @do_devoice
      User("Chanserv").send("devoice #reddit-mlpds hushnowquietnow")
    end
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
      return
    rescue Exception
      m.reply "No matching class found for #{plugin} to reload"
    end

    @bot.plugins.register_plugin(plugin_class)
    m.reply "Okay."
  end
end
