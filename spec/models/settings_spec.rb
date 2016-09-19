require 'spec_helper'

describe Settings do

  describe '::defaults' do
    it 'not raises errors without parameters' do
      expect{ Settings.defaults {} }.to_not raise_error
    end

    it 'returns default value for simple value' do
      word = Faker::Lorem.word
      Settings.defaults{|s| s.cached_key = word}
      p Settings.all
      expect( Settings.cached_key ).to eq(word)
    end

    it 'returns default value for complex value' do
      word = Faker::Lorem.word
      Settings.defaults{|s| s.some.key = word}
      p Settings.all
      p Settings.some.methods
      expect( Settings.some.key ).to eq(word)
    end
  end

  describe '::from_hash' do
    it 'accessable by hash key' do
      Settings.from_hash(hello: :world)
      expect( Settings.hello ).to eq(:world)
    end
  end

  describe 'general' do
    it 'not raises error on create new instance of Settings' do
      expect{ Settings.new }.to_not raise_error
    end
    it 'not raises error on create new element' do
      expect{ Settings.hello = Faker::Lorem.word }.to_not raise_error
    end
    it 'returns same Fixnum' do
      word = Faker::Lorem.word
      Settings.number = 100
      expect( Settings.number ).to eq(100)
    end
    it 'returns same String' do
      word = Faker::Lorem.word
      Settings.hello = word
      expect( Settings.hello ).to eq(word)
    end
    it 'returns same value for complex key #1' do
      word = Faker::Lorem.word
      Settings.hello.hello = word
      expect( Settings.hello.hello ).to eq(word)
    end
    it 'returns same value for complex key #2' do
      word = Faker::Lorem.word
      Settings.i.hello = word
      expect( Settings.i.hello ).to eq(word)
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

end
