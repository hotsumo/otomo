require 'spec_helper'

describe Otomo do
  it 'has a version number' do
    expect(Otomo::VERSION).not_to be nil
  end

  it 'can transform hash to www-url-encoded' do
    url_encoded = Otomo.hash_to_www_url_encoded({a: { c: 1, d: [1,2,3] }, b: [1,2,3], c: "test"})

    expect(url_encoded).to eql "a[c]=1&a[d][]=1&a[d][]=2&a[d][]=3&b[]=1&b[]=2&b[]=3&c=test"
  end

  it 'can ask with query' do
    Otomo.session "http://www.google.com" do
      
      doc = get "?gfe_rd=cr&ei=JtyTVu2WCOvC8Af6noyAAQ#q=test"
      puts doc.inspect
    end
  end

end
