class Settingson::Store

  def initialize(klass:, path: nil)
    @__klass  = klass
    @__path   = path
  end

  def to_s
    ''
  end

  def to_i
    0
  end

  def nil?
    true
  end

  def to_a
    []
  end

  def to_key
    nil
  end

  alias empty? nil?
  alias to_ary to_a

  def method_missing(symbol, *args)
    __debug(caller)
    __rescue_action(symbol.to_s, args)
  end # method_missing

  protected
  # TODO: move all methods to support class
  def __debug(message)
    message = sprintf("%s#%-24s: %s",
                      self.class.name,
                      caller_locations.first.label,
                      message)
    Rails.logger.debug(message) if @__klass.configure.debug
  end

  def __rescue_action(key, value)
    __debug("key: #{key}:#{key.class} value: #{value}:#{value.class} " +
            "path: '#{@__path}'")
    case key
    when '[]'     # object reference
      __debug("reference '#{value.first}'")
      __get( __reference(value.first) )
    when '[]='    # object reference setter
      __debug("reference setter '#{value.first}' '#{value.last}'")
      __set( __reference(value.first), value.last )
    when /(.+)=/  # setter
      __debug("set '#{$1}' value '#{value.first}'")
      __set($1, value.first)
    else          # returns values or self
      __debug("get '#{key}'")
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

  # @profile = Profile.first # any ActiveRecord::Base object
  # Settings[@profile].some.host = 'value'
  def __reference(key)
    case key
    when String
      key
    when Symbol
      key.to_s
    when ActiveRecord::Base
      class_name = __underscore(key.class)
      ref_id = __reference_id(key)
      "#{class_name}_#{ref_id || 'new'}"
    else
      raise ArgumentError.new(
        'String/Symbol/ActiveRecord::Base variable required'
      )
    end
  end

  def __underscore(camel_cased_word)
    word = camel_cased_word.to_s.dup
    word.gsub!(/::/, '_')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!('-', '_')
    word.downcase!
    word
  end

  def __reference_id(key)
    key.try(:to_key).try(:join, '_') || key.id
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
