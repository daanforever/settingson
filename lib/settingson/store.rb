class Settingson::Store

  require 'settingson/store/default'
  require 'settingson/store/general'

  def initialize(klass:, path: nil)
    @__klass    = klass
    @__path     = path
    @__config   = klass.configure
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
  alias to_str to_s

  def method_missing(symbol, *args)
    __debug
    __debug("from\n\t#{caller[1..@__config.trace].join("\n\t")}") if
      @__config.trace > 0

    __references_action(symbol, *args) or __rescue_action(symbol.to_s, *args)
    # __rescue_action(symbol.to_s, *args)
  end # method_missing

  protected
  # TODO: move all methods to support class
  def __debug(message="")
    return unless @__config.debug
    message = sprintf("%s#%20s: %s",
                      self.class.name,
                      caller_locations.first.label,
                      message)
    Rails.logger.debug(message)
  end

  def __references_action(symbol, *args)
    # Proxy pass only one method
    # return nil
    # return nil unless ['model_name', 'to_model'].include?(symbol.to_s)
    if @__klass and @__klass.respond_to?(symbol)
      __debug("#{@__klass} know what to do with #{symbol}")
      @__klass.send(symbol, *args)
    end
  end

  def __rescue_action(key, *args)
    __debug("key: #{key}:#{key.class} args: #{args}:#{args.class} " +
            "path: '#{@__path}'")
    case key
    when '[]'     # object reference[, with :field]
      __debug("reference '#{args}'")
      __get( __with_reference(args[0], args[1]) )
    when '[]='    # object reference setter
      __debug("reference setter '#{args}'")
      if args.size == 3 # [@setting, :key]= form
        __set( __with_reference(args[0], args[1]), args[2] )
      else # [@settings]= form
        __set( __with_reference(args.first), args.last )
      end
    when /(.+)=/  # setter
      __debug("set '#{$1}' args '#{args.first}'")
      __set($1, args.first)
    else          # returns result or self
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

    Rails.cache.write(__cache_key(@__path), value) if @__config.cache.enabled
    value
  end

  def __get(key)
    __update_search_path(key)
    result = __look_up_value(@__path)

    if result.is_a?(ActiveRecord::RecordNotFound) or
       result.is_a?(Settingson::Store::Default)
      __debug("return self with path: #{@__path}")
      self
    else
      __debug("return result")
      result
    end
  end

  # @profile = Profile.first # any ActiveRecord::Base object
  # Settings[@profile].some.host = 'value'
  def __with_reference(key, field=nil)
    case key
    when String
      key
    when Symbol
      key.to_s
    when ActiveRecord::Base
      @__reference = key
      if field.nil?
        class_name = __underscore(key.class)
        ref_id = __reference_id(key)
        "#{class_name}_#{ref_id || 'new'}"
      else
        key.send(field.to_sym)
      end
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

  def _search_path(key)
    [@__path, key].compact.join('.')
  end

  def __update_search_path(key)
    @__path = _search_path(key)
  end

  def __look_up_value(key)
    result = @__config.cache.enabled ? __from_cache(key) : __from_db(key)

    if result.is_a?(ActiveRecord::RecordNotFound)
      __debug("looking in #{@__klass.name}.defaults[#{key}]")
      @__klass.defaults[key]
    else
      result
    end
  end

  def __cache_key(key)
    [ @__config.cache.namespace, key ].join('/')
  end

  def __from_cache(key)
    __debug("looking in cache '#{__cache_key(key)}'")
    Rails.cache.fetch(
      __cache_key(key),
      expires_in:         @__config.cache.expires,
      race_condition_ttl: @__config.cache.race_condition_ttl
    ) do
      __debug("ask DB '#{key}'")
      __from_db(key)
    end
  end

  def __from_db(key)
    @__klass.find_by!(key: key).value
  rescue ActiveRecord::RecordNotFound
    __debug("not found")
    ActiveRecord::RecordNotFound.new
  end

end
