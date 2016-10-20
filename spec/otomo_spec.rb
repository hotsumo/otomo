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

  it 'return the net/http request in raw mode' do
    _self = self

    Otomo.session "http://www.google.com" do |otomo|
      otomo.raw_mode!

      x = otomo.get "/"

      expect(x.class).to be(Net::HTTPOK)
    end
  end

  it "can connect through a socks proxy" do
    require 'timeout'

    pid = Process.spawn("ssh -N -D 8888 -i proxy.key root@104.199.215.92 1>/dev/null")
    #Process.detach(pid)

    begin
      puts "pid = #{pid}"
      sleep 5

      Otomo.session "http://bot.whatismyipaddress.com",
        proxy: { type: :socks, host: 'localhost', port: '8888' } do |otomo|
        otomo.raw_mode!
        x = otomo.get "/"
        expect(x.body).to eq("104.155.228.61")
      end
    ensure
      puts "KILL PROCESS!"
      # Fuck children processes ! ~.~
      `kill $(pgrep -P #{pid})`
      Process.kill( 15, pid)
      next_signal = 2
      begin
        Timeout::timeout(3) { Process.wait(pid) }
      rescue
        Process.kill(next_signal, pid)
        next_signal = 9 if next_signal==2
        retry
      end
    end
  end

end
