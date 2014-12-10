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
end