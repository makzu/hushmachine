module Shushable

  def shush(m)
    @shushed = true
  end

  def unshush(m)
    @shushed = false
  end

  def shushed?
    @shushed ||= false
  end

end
