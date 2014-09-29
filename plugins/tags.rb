require 'cinch'
require 'json'

class Tags
  include Cinch::Plugin

  set :help, "\cB!tags\cB - get all subjects with tags\n"\
             "\cB!tag <subject>\cB / \cB?<subject>\cB - get all tags for <subject>\n"\
             "\cB!mytags\cB / \cB!me\cB - get your own tags\n"\
             "\cB!tag <add/del> <subject> <tag>\cB / \cB!addtag <subject> <tag>\cB / \cB!deltag <subject> <tag>\cB = add or remove <tag> for <subject>"

  match /tags? (?!add|del)(.+)/i, method: :tags
  match /(\S+)/, prefix: "?", method: :tags
  match /(all)?tags?$/i, method: :alltags

  match /tags? add (\S+) (.+)/i, method: :addtag
  match /addtags? (\S+) (.+)/i, method: :addtag

  match /tags? (?:del|delete|remove) (\S+) (.+)/i, method: :deltag
  match /(?:del|delete|remove)tags? (\S+) (.+)/i, method: :deltag

  match /tags? clear (\S+)/i, method: :cleartag
  match /cleartags? (\S+)/i, method: :cleartag

  match /(\S+)/, method: :maybe_tags

  match /reloadtags$/i, method: :check_reload

  def initialize(*args)
    super
    @tags = {}
    load_tags
    @banlist = config[:banlist]
    @allowed_channels = config[:allowed_channels]
    info "!tags initialized with tags for #{@tags.length} subjects"
  end

  def alltags(m)
    if @tags == {}
      m.reply "I have no tags :("
    else
      m.reply "Check your PMs, #{m.user.to_s}" if m.channel?
      m.user.msg "I have tags for: " + Format(:blue, @tags.keys.collect { |t| @tags[t]['name'] }.sort { |a, b| a.downcase <=> b.downcase }.join(", "))
    end
  end

  def addtag(m, subject, tag)
    if @banlist.include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless m.channel? and @allowed_channels.include? m.channel.to_s
      m.reply "Modifying tags outside the main channel is disabled."
      return
    end

    u = subject.downcase

    if %w{me myself mytags}.include? u
      m.reply "#{Format(:bold, u)} is reserved."
      return
    end

    @tags[u] = { 'name' => subject, 'tags' => [] } if @tags[u].nil?
    @tags[u]['tags'] << tag.force_encoding("UTF-8")
    @tags[u]['tags'].sort_by!(&:downcase).uniq!
    m.reply "Added #{tag} for #{Format(:blue, @tags[u]['name'])}."
    save_tags
  end

  def deltag(m, subject, tag)
    if @banlist.include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless m.channel? and @allowed_channels.include? m.channel.to_s
      m.reply "Modifying tags outside the main channel is disabled."
      return
    end

    u = subject.downcase

    if @tags[u].nil?
      m.reply "No tags for #{Format(:blue, subject)}."
    elsif @tags[u]['tags'].include? tag
      name = @tags[u]['name']

      @tags[u]['tags'].reject! { |x| x == tag }
      @tags.delete u if @tags[u]['tags'].empty?

      m.reply "Removed #{tag} from #{Format(:blue, name)}."
      save_tags
    else
      m.reply "#{Format(:blue, @tags[u]['name'])} doesn't have that tag."
    end
  end

  def cleartag(m, subject)
    if @banlist.include?(m.user.user.downcase)
      m.reply "You're not allowed to do that."
      return
    end
    unless m.channel? and @allowed_channels.include? m.channel.to_s
      m.reply "Modifying tags outside the main channel is disabled."
      return
    end

    u = subject.downcase

    if @tags[u].nil?
      m.reply "No tags for #{Format(:blue, subject)}."
    else
      name = @tags[u]['name']

      @tags.delete u

      m.reply "Removed all tags from #{Format(:blue, name)}."
      save_tags
    end
  end

  def tags(m, subject)
    s = subject
    u = s.downcase

    if %w{me myself mytags}.include? u
      u = m.user.to_s.downcase
      s = m.user.to_s
    end

    if @tags[u].nil?
      m.reply "No tags for #{Format(:blue, s)}."
    else
      m.reply "Tags for #{Format(:blue, @tags[u]['name'])}: #{@tags[u]['tags'].join(' ')}"
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
    @tags = JSON.parse File.read('tagfile') rescue {}
  end

  def save_tags
    @tags = Hash[@tags.sort]

    File.open("tagfile", "w") { |f| f.write JSON.pretty_generate @tags }
  end
end
