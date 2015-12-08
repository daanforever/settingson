require 'spec_helper'

describe Settings do

  describe 'Settings.defaults' do
    # very bad spec. TODO: rewrite me
    it 'not raises errors' do
      expect{ Settings.default {} }.to_not raise_error
    end
  end

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

  it 'destroys record with nil value #1' do
    word = Faker::Lorem.word
    Settings.some = word
    expect{ Settings.some = nil }.to change{ Settings.count }.by(-1)
  end

  it 'destroys record with nil value #2' do
    word = Faker::Lorem.word
    Settings.some.hello = word
    expect{ Settings.some.hello = nil }.to change{ Settings.count }.by(-1)
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
end
