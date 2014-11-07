require 'cinch'
require 'yaml'

class Tags
  include Cinch::Plugin

  set :help, "\cB!tags\cB - get all subjects with tags\n"\
             "\cB!tag <subject>\cB / \cB?<subject>\cB - get all tags for <subject>\n"\
             "\cB!mytags\cB / \cB!me\cB - get your own tags\n"\
             "\cB!tag <add/del> <subject> <tag>\cB / \cB!addtag <subject> <tag>\cB / \cB!deltag <subject> <tag>\cB = add or remove <tag> for <subject>"

  match /tags? (?!add|del|alias[add|del|remove|for|list]|listalias)(.+)/i, method: :tags
  match /(\S+)/, prefix: "?", method: :tags
  match /(all)?tags?$/i, method: :alltags

  match /tags? add (\S+) (.+)/i, method: :addtag
  match /addtags? (\S+) (.+)/i, method: :addtag

  match /tags? (?:del|delete|remove) (\S+) (.+)/i, method: :deltag
  match /(?:del|delete|remove)tags? (\S+) (.+)/i, method: :deltag

  match /tags? clear (\S+)/i, method: :cleartag
  match /cleartags? (\S+)/i, method: :cleartag

  match /tags? (?:aliasadd|addalias) (\S+) (\S+)/i, method: :addalias
  match /addtagalias (\S+) (\S+)/i, method: :addalias

  match /tags? aliasdel (\S+)/i, method: :delalias
  match /(?:del|delete|remove)tagalias (\S+)/i, method: :delalias

  match /tags? (?:aliaslist|listalias)$/i, method: :allaliases

  match /tags? aliasfor (\S+)/i, method: :aliasfor

  match /(\S+)/, method: :maybe_tags

  match /reloadtags$/i, method: :check_reload

  def initialize(*args)
    super
    load_tags
    @allowed_channels = config[:allowed_channels]
    info "!tags initialized with tags for #{@data[:taglist].length} subjects"
  end

  def alltags(m)
    if @data[:taglist].empty?
      m.reply "I have no tags :("
    else
      m.reply "Check your PMs, #{m.user.to_s}" if m.channel?
      m.user.msg "I have tags for: " + Format(:blue, @data[:taglist].keys.collect { |t| @data[:taglist][t][:name] }.sort { |a, b| a.downcase <=> b.downcase }.join(", "))
    end
  end

  def addtag(m, subject, tag)
    if @data[:blacklist].include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless can_edit?(m)
      m.reply "Modifying tags outside the main channel is disabled. Ask Hush if you want to be added to the whitelist."
      return
    end

    u = subject.downcase

    if %w{me myself mytags}.include? u
      m.reply "#{Format(:bold, u)} is reserved."
      return
    end

    @data[:taglist][u] = { name: subject, tags: [] } if @data[:taglist][u].nil?
    @data[:taglist][u][:tags] << tag.force_encoding("UTF-8")
    m.reply "Added #{tag} for #{Format(:blue, @data[:taglist][u][:name])}."
    save_tags
  end

  def deltag(m, subject, tag)
    if @data[:blacklist].include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless can_edit?(m)
      m.reply "Modifying tags outside the main channel is disabled. Ask Hush if you want to be added to the whitelist."
      return
    end

    u = subject.downcase

    if @data[:taglist][u].nil?
      m.reply "No tags for #{Format(:blue, subject)}."
    elsif @data[:taglist][u][:tags].include? tag
      name = @data[:taglist][u][:name]

      @data[:taglist][u][:tags].reject! { |x| x == tag }
      @data.delete u if @data[:taglist][u][:tags].empty?

      m.reply "Removed #{tag} from #{Format(:blue, name)}."
      save_tags
    else
      m.reply "#{Format(:blue, @data[:taglist][u][:name])} doesn't have that tag."
    end
  end

  def cleartag(m, subject)
    if @data[:blacklist].include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless can_edit?(m)
      m.reply "Modifying tags outside the main channel is disabled. Ask Hush if you want to be added to the whitelist."
      return
    end

    u = subject.downcase

    if @data[:taglist][u].nil?
      m.reply "No tags for #{Format(:blue, subject)}."
    else
      name = @data[:taglist][u][:name]

      @data[:taglist].delete u

      m.reply "Removed all tags from #{Format(:blue, name)}."
      save_tags
    end
  end

  def tags(m, subject)
    s = subject
    u = s.downcase

    if %w{me myself mytags}.include? u
      s = m.user.to_s
      u = s.downcase
    end

    if @data[:aliases].include? u
      s = @data[:aliases][u]
      u = s.downcase
    end

    if @data[:taglist][u].nil?
      m.reply "No tags for #{Format(:blue, s)}."
    else
      m.reply "Tags for #{Format(:blue, @data[:taglist][u][:name])}: #{@data[:taglist][u][:tags].join(' ')}"
    end
  end

  def addalias(m, name, target)
    if @data[:blacklist].include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless can_edit?(m)
      m.reply "Modifying tags outside the main channel is disabled. Ask Hush if you want to be added to the whitelist."
      return
    end
    if @data[:taglist][target.downcase].nil?
      m.reply "#{Format(:blue, target)} is not a valid tag!"
    elsif ! @data[:taglist][name.downcase].nil?
      m.reply "#{Format(:blue, name)} is already a tag itself!"
    else
      @data[:aliases][name.downcase] = target.downcase
      m.reply "Added #{Format(:blue, name)} as an alias for #{ Format(:blue, @data[:taglist][target.downcase][:name]) }."
      save_tags
    end
  end

  def delalias(m, name)
    if @data[:blacklist].include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless can_edit?(m)
      m.reply "Modifying tags outside the main channel is disabled. Ask Hush if you want to be added to the whitelist."
      return
    end

    @data[:aliases].delete name.downcase
    m.reply "Removed alias #{Format(:blue, name)}."
    save_tags
  end

  def aliaslist(m)
  end

  def aliasfor(m, name)
    t = @data[:aliases].select{ |k, v| v.downcase == name.downcase }.keys
    if t.length == 0
      m.reply "There are no aliases for #{Format(:blue, name)}."
    else
      m.reply "Aliases for #{Format(:blue, name)}: #{array_to_sentence(t)}"
    end
  end

  def maybe_tags(m, subject)
    case subject
    when "stats"
      tags(m, subject)
    when "me", "myself","mytags"
      tags(m, m.user.to_s)
    end
  end

  def check_reload(m)
    log "!!!!!!!!!!!!!!!!!!!!!!!!! Got a checkreload command from #{m.user.authname}"
    if m.user.authname == "hushnowquietnow"
      load_tags
      m.reply "Okay."
    end
  end

  private
  def load_tags
    @data = YAML.load_file('tagfile.yaml') rescue {whitelist: [], blacklist: [], aliases: {}, allowed_channels: ['#reddit-mlpds'], taglist: {}}
  end

  def save_tags
    sort_tags
    File.open("tagfile.yaml", "w") { |f| f.write @data.to_yaml }
  end

  def can_edit?(m)
    return true if m.user.authname and @data[:whitelist].include? m.user.authname.downcase
    m.channel? and @data[:allowed_channels].include? m.channel
  end

  def sort_tags
    @data[:whitelist].sort!.uniq!
    @data[:blacklist].sort!.uniq!

    @data[:aliases] = @data[:aliases].sort_by(&:last).to_h

    nh = {}
    @data[:taglist].keys.sort.each do |t|
      nh[t] = {}
      nh[t][:name] = @data[:taglist][t][:name]
      nh[t][:tags] = @data[:taglist][t][:tags].sort_by(&:downcase)
    end
    @data[:taglist] = nh

  end

  def array_to_sentence(ary)
    case ary.length
      when 0
        ""
      when 1
        ary[0].to_s.dup
      when 2
        "#{ary[0]} and #{ary[1]}"
      else
        "#{ary[0..-2].join(", ")}, and #{ary[-1]}"
    end
  end
end
