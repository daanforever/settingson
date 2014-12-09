require 'spec_helper'

describe Settings do
  it 'not raise error' do
    expect{ Settings.new }.to_not raise_error
  end
end