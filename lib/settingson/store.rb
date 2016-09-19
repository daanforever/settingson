class Settingson::Store

  def initialize(klass:, path: nil)
    @__klass  = klass
    @__path   = path
  end

  def to_s
    self.new_record? ? '' : super
  end

  def to_i
    self.new_record? ? 0 : super
  end

  def nil?
    self.new_record? ? true : super
  end

  alias empty? nil?

  def method_missing(symbol, *args)
    __rescue_action(symbol.to_s, args.first)
  end # method_missing

  protected

  def __debug(message)
    message = sprintf("%s#%-32s: %s",
                      self.class.name,
                      caller_locations.first.label,
                      message)
    Rails.logger.debug(message) if @__klass.configure.debug
  end

  def __rescue_action(key, value)
    case key
    when /(.+)=/  # setter
      __debug("set '#{$1}' value '#{value}' path '#{@__path}'")
      __set($1, value)
    else # returns values or self
      __debug("get '#{key}' value '#{value}' path '#{@__path}'")
      __get(key)
    end
  end

  def __set(key, value)
    __update_search_path(key)
    if record = @__klass.find_by(key: @__path)
      record.update!(value: value)
    else
      @__klass.create!(key: @__path, value: value)
    end
    Rails.cache.write(__cache_key(@__path), value)
    value
  end

  def __get(key)
    __update_search_path(key)
    result = __cached_or_default_value(@__path)

    if result.is_a?(ActiveRecord::RecordNotFound)
      __debug("return self with path: #{@__path}")
      self
    else
      __debug("return result")
      result
    end
  end

  def __update_search_path(key)
    @__path = [@__path, key].compact.join('.')
  end

  def __cached_or_default_value(key)
    result = __cached_value(key)

    if result.is_a?(ActiveRecord::RecordNotFound) # Try defaults
      __cached_value('__defaults.' + key)
    else
      result
    end
  end

  def __cache_key(key)
    [ @__klass.configure.cache.namespace, key ].join('/')
  end

  def __cached_value(key)
    __debug("looking in cache '#{__cache_key(key)}'")
    Rails.cache.fetch(
      __cache_key(key),
      expires_in:         @__klass.configure.cache.expires,
      race_condition_ttl: @__klass.configure.cache.race_condition_ttl
    ) do
      __debug("ask DB '#{key}'")
      __get_from_db(key)
    end
  end

  def __get_from_db(key)
    @__klass.find_by!(key: key).value
  rescue ActiveRecord::RecordNotFound
    __debug("not found")
    ActiveRecord::RecordNotFound.new
  end

end
