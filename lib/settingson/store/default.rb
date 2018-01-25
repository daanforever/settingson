class Settingson::Store::Default < Settingson::Store

  @@__defaults = {}

  def to_h
    @@__defaults
  end

  def to_ary
    @@__defaults.to_a
  end

  protected
  def __set(key, value)
    @@__defaults[_search_path(key)] = value
    @__path = nil
    value
  end

  def __get(key)
    __update_search_path(key)
    @@__defaults[@__path] || self
  end

end
