class Settingson::Defaults
  def initialize(klass:)
    @__klass  = klass
    @__path   = '__defaults'
  end # initialize

  def method_missing(symbol, *args)
    Settingson::Store.new(
      klass: @__klass, path: @__path, defaults: true
    ).send(symbol, *args)
  end # method_missing
end
