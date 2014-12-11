require 'spec_helper'

describe Settings do
  it 'not raises error on create new instance of Settings' do
    expect{ Settings.new }.to_not raise_error
  end
  it 'not raises error on create new element' do
    expect{ Settings.hello = Faker::Lorem.word }.to_not raise_error
  end
  it 'returns same value' do
    word = Faker::Lorem.word
    Settings.hello = word
    expect( Settings.hello ).to eq(word)
  end
  it 'returns same value for composit (1)' do
    word = Faker::Lorem.word
    Settings.hello.hello = word
    expect( Settings.hello.hello ).to eq(word)
  end
  it 'returns same value for composit (2)' do
    word = Faker::Lorem.word
    Settings.i.hello = word
    expect( Settings.i.hello ).to eq(word)
  end

  it 'destroys record with nil value (1)' do
    word = Faker::Lorem.word
    Settings.some = word
    expect{ Settings.some = nil }.to change{ Settings.count }.by(-1)
  end

  it 'destroys record with nil value (2)' do
    word = Faker::Lorem.word
    Settings.some.hello = word
    expect{ Settings.some.hello = nil }.to change{ Settings.count }.by(-1)
  end

end