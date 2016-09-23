require 'spec_helper'

describe Settings do

  describe '::defaults' do
    it 'not raises errors without parameters' do
      expect{ Settings.defaults {} }.to_not raise_error
    end

    it 'returns default value for simple value' do
      word = Faker::Lorem.word
      Settings.defaults{|s| s.cached_key = word}
      expect( Settings.cached_key ).to eq(word)
    end

    it 'returns default value for complex value' do
      word = Faker::Lorem.word
      Settings.defaults{|s| s.some.key = word}
      expect( Settings.some.key ).to eq(word)
    end
  end

  describe '::from_hash' do
    it 'accessable by hash key' do
      Settings.from_hash(hello: :world)
      expect( Settings.hello ).to eq(:world)
    end

    it 'raises error when not Hash' do
      expect{Settings.from_hash([:hello, :world])}.to raise_error(ArgumentError)
    end
  end

  describe 'general' do
    it 'not raises error on create new instance of Settings' do
      expect{ Settings.new }.to_not raise_error
    end
    it 'not raises error on create new element' do
      expect{ Settings.hello = Faker::Lorem.word }.to_not raise_error
    end
    it 'returns same Fixnum #1' do
      Settings.number = 100
      expect( Settings.number ).to eq(100)
    end
    it 'pass simple checks' do
      expect( Settings.not_found.to_s ).to eq("")
      expect( Settings.not_found.to_i ).to eq(0)
      expect( Settings.not_found.to_a ).to eq([])
      expect( Settings.not_found.to_key ).to eq(nil)
      expect( Settings.not_found.nil? ).to eq(true)
      expect( Settings.not_found.empty? ).to eq(true)
      expect( Settings.not_found.blank? ).to eq(true)
      expect( Settings.not_found.present? ).to eq(false)
    end
    it 'returns same String' do
      word = Faker::Lorem.word
      Settings.hello = word
      expect( Settings.hello ).to eq(word)
    end
    it 'returns same value for complex key #1' do
      word = Faker::Lorem.word
      Settings.hello1.hello2 = word
      expect( Settings.hello1.hello2 ).to eq(word)
    end
    it 'returns same value for complex key #2' do
      word = Faker::Lorem.word
      Settings.hello.key = word
      expect( Settings.hello.key ).to eq(word)
    end
    it 'returns same value for complex key #3' do
      word = Faker::Lorem.word
      Settings.hello.hello = word
      expect( Settings.hello.hello ).to eq(word)
    end
    it 'not destroys record with nil value #1' do
      word = Faker::Lorem.word
      Settings.some = word
      expect{ Settings.some = nil }.to change{ Settings.count }.by(0)
    end

    it 'not destroys record with nil value #2' do
      Settings.some.hello = Faker::Lorem.word
      expect{ Settings.some.hello = nil }.to change{ Settings.count }.by(0)
    end
  end

  describe 'with empty value' do
    it 'returns empty string' do
      expect( "#{Settings.not_found}" ).to eq("")
    end

    it 'returns value.nil? is true' do
      expect( Settings.not_found.nil? ).to be(true)
    end

    it 'returns value.empty? is true' do
      expect( Settings.not_found.empty? ).to be(true)
    end

    it 'returns value.blank? is true' do
      expect( Settings.not_found.blank? ).to be(true)
    end

    it 'returns value.present? is false' do
      expect( Settings.not_found.present? ).to be(false)
    end
  end

  describe 'caching' do
    it 'delete key before destroy' do
      Settings.some.hello = Faker::Lorem.word
      Settings.all.each{|e| e.destroy! }
      expect( Rails.cache.exist?('settingson_cache/some.hello') ).to be false
    end

    it 'returns empty value after destroy' do
      Settings.some.hello = Faker::Lorem.word
      Settings.all.each{|e| e.destroy! }
      expect( Settings.some.hello ).to be_empty
    end

    it 'clear cache on ::delete_all for simple key' do
      Settings.hello = Faker::Lorem.word
      Settings.delete_all
      expect( Settings.hello ).to be_empty
    end

    it 'clear cache on ::delete_all for complex key' do
      Settings.some.hello = Faker::Lorem.word
      Settings.delete_all
      expect( Settings.some.hello ).to be_empty
    end
  end

  describe '::[]' do
    it 'raises error with unknown class' do
      expect{ Settings[Time.new] }.to raise_error(ArgumentError)
    end
    it 'returns Settingson::Store instance' do
      expect( Settings['hello'] ).to be_a(Settingson::Store)
    end
    it 'returns instance with search path "hello" for simple' do
      settings = Settings['hello']
      expect( settings.instance_variable_get(:@__path) ).to eq('hello')
    end
    it 'returns instance with search path "hello.message" for complex #1' do
      settings = Settings[:hello].message
      expect( settings.instance_variable_get(:@__path) ).to eq('hello.message')
    end

    it 'Settings[:say] form' do
      Settings[:say] = 'hello'
      expect( Settings.say ).to eq('hello')
    end
    it 'Settings[@setting, :key] form' do
      setting = Settings.create!(key: 'test_key', value: 'test_value')
      Settings[setting, :value] = 'hello'
      expect( Settings.test_value ).to eq('hello')
    end
    it 'Settings[:say].hello == Settings.say[:hello]' do
      Settings[:say].hello = 'hello'
      expect( Settings.say[:hello] ).to eq('hello')
    end
    it 'works with complex check' do
      Settings[:greeting].welcome.message = 'Hello'
      expect( Settings[:greeting].welcome.message  ).to eq('Hello')
      expect( Settings.greeting[:welcome].message  ).to eq('Hello')
      expect( Settings.greeting.welcome[:message]  ).to eq('Hello')
      expect( Settings.greeting.welcome['message'] ).to eq('Hello')
    end
    it 'returns instance with search path "settings_1"' do
      s = Settings.create(key: 'hello', value: 'world')
      expect( Settings[s].instance_variable_get(:@__path) ).to eq("settings_1")
    end
  end

end
