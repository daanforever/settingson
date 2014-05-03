class Settingson::Store

  attr_accessor :name, :value

  def initialize(klass, string, *args)
    @klass  = klass
    @value  = parse(string, args.first)
  end

  def to_s
    @value
  end

  def to_ary
    [ @value ]
  end

  def nil?
    true
  end

  def [](*args)
    return nil if args.nil?
    if args.count == 1
      result = @klass.find_by(name: "#{@name}.#{args.first}").try(:value)
      result.nil? ? nil : YAML.load(result)
    else
      args.map do |subname|
        result = @klass.find_by(name: "#{@name}.#{subname}").try(:value)
        result.nil? ? nil : YAML.load(result)
      end
    end
  end

  def []=(*args)
    return nil if args.nil?
    if args.count == 2
      if record = @klass.find_by(name: "#{@name}.#{args.first}")
        record.update(value: args.last.to_yaml)
      else
        @klass.create(name: "#{@name}.#{args.first}", value: args.last.to_yaml)
      end
      args.last
    elsif args.count > 2
      values = args.pop
      args.map do |subname|
        value = values.shift
        if record = @klass.find_by(name: "#{@name}.#{subname}")
          record.update(value: value.to_yaml)
        else
          @klass.create(name: "#{@name}.#{subname}", value: value.to_yaml)
        end
        value
      end
    end
  end

  def method_missing(string, *args)
    @value   = parse(string, args.first)
  end

  protected
  def parse(string, value)
    case string.to_s
    when /(.+)=/
      @name = @name.nil? ? $1 : @name + ".#{$1}"
      if record = @klass.find_by(name: @name)
        if value.nil?
          record.destroy
        else
          record.update(value: value.to_yaml)
        end
        value
      else
        @klass.create(name: @name, value: value.to_yaml) unless value.nil?
        value
      end
    else
      @name = @name.nil? ? string.to_s : @name + ".#{string.to_s}"
      if result = @klass.find_by(name: @name)
        YAML.load result.value
      else
        self
      end
    end
  end
end