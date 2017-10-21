require 'spec_helper'

describe Settingson::Default do

  it 'not raises errors with empty block' do
    expect{ Settings.defaults {} }.to_not raise_error
  end

  it 'returns value for given key' do
    word = Faker::Lorem.word
    h = Settings.defaults{|s| s.cached_key = word}
    expect( h['cached_key'] ).to eq(word)
  end

  it 'returns value for given key #2' do
    word = Faker::Lorem.word
    h = Settings.defaults do |s|
      s.cached_key1 = word
      s.cached.key2 = word
    end
    expect( h['cached.key2'] ).to eq(word)
  end

end
