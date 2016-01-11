require 'spec_helper'

describe Otomo do
  it 'has a version number' do
    expect(Otomo::VERSION).not_to be nil
  end

  it 'can transform hash to www-url-encoded' do
    puts Otomo.hash_to_www_url_encoded({a: { c: 1, d: [1,2,3] }, b: [1,2,3], c: "test"})
  end

end
