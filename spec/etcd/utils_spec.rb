require 'spec_helper'

describe Etcd::Utils do
  it 'has a version number' do
    expect(Etcd::Utils::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
