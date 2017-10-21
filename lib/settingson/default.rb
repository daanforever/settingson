class Settingson::Default
  require 'settingson/default/store'

  def initialize(klass:)
    @__klass  = klass
  end # initialize

  def method_missing(symbol, *args)
    Settingson::Default::Store.new( klass: @__klass ).send(symbol, *args)
  end # method_missing
end
