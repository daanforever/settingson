class Settingson::Config
  attr_accessor :cache

  def initialize
    @cache = OpenStruct.new(expires_in: 60.seconds,
                            race_condition_ttl: 10.seconds,
                            enabled: true)
  end
end
