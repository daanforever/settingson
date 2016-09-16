class Settingson::Config
  attr_accessor :cache
  attr_accessor :debug

  def initialize
    @debug = false
    @cache = OpenStruct.new(expires_in: 60.seconds,
                            race_condition_ttl: 10.seconds,
                            enabled: true,
                            namespace: "settingson/#{Rails.env}"
                            )
  end
end
