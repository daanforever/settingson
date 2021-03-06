class Settingson::Config
  attr_accessor :cache
  attr_accessor :debug
  attr_accessor :trace

  def initialize
    @debug = false
    @trace = 0
    @cache = OpenStruct.new(expires_in: 60.seconds,
                            race_condition_ttl: 10.seconds,
                            enabled: true,
                            namespace: "settingson/#{Rails.env}"
                            )
    @cache.enabled = false if Rails.env.test?
  end
end
