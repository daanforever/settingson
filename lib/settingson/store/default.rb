class Settingson::Store::Default < Settingson::Store

  @@__defaults = {}

  def to_h
    @@_defaults
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

  def __reference_id(key)
    key.try(:to_key).try(:join, '_') || key.id
  end

end
