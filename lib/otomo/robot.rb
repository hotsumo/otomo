require 'net/http'
require 'nokogiri'

module Otomo
  class Robot

    attr_accessor :scheme, :host, :port

    attr_accessor :cookies, :referer

    attr_reader http

    attr_accessor :raw_mode #Do not use response handlers at all.

    attr_accessor :header

    def initialize path, header={}
      @header = header
      @raw_mode = false

      if path.is_a?(String)
        uri = URI(path)
        @scheme = uri.scheme
        @host = uri.host
      end
    end

    def current_port
      port || default_port
    end

    def use_ssl= x; @use_ssl = x; end

    def use_ssl?
      if @use_ssl.nil?
        (@scheme == "https")
      else
        @use_ssl
      end
    end

    def connect
      self.http = Net::HTTP.new(@host, current_port)
      http.use_ssl = (@scheme == "https")
    end

    def full_path path
      if path =~ URI::regexp
        path
      else
        "#{@scheme}://#{@host}" + File.join("/", path)
      end
    end

    def get path
      resp = if path =~ URI::regexp
        http.get(URI(path).path, prepare_headers)
      else
        http.get(File.join("/", path), prepare_headers)
      end

      handle_response resp do
        set_cookies resp.get_fields('set-cookie')
        @referer = full_path(path)
      end
    end

    def html_document string
      Nokogiri::HTML(string)
    end

    def post path, data
      if data.is_a?(Hash)
        data = Otomo.hash_to_www_url_encoded(data)
      end

      resp = http.post(File.join("/", path), data, prepare_headers)

      File.write("tmp.html", resp.body)

      handle_response resp do
        set_cookies resp.get_fields('set-cookie')
        @referer = full_path(path)
      end
    end

  def add_cookie key, value
    @cookies ||= {}
    @cookies[key] = value
  end

  def remove_cookie c
    @cookies.delete(c)
  end

  def clear_cookies
    @cookies = {}
  end

private

  def set_cookies from_array
    if from_array!=nil
      @cookies = Hash[ from_array.map{|elm| (elm.split("; ")[0].split("="))  }]
    end
  end

  def get_cookies
    if @cookies
      @cookies.map{|k,v| "#{k}=#{v}"}.join("; ")
    else
      nil
    end
  end

  def prepare_headers
    @header.merge({
      'Cookie' => get_cookies,
      'Referer' => referer
    }).reject{ |k,v| v.nil? || v.empty? }
  end

  def handle_response resp
    case resp
    when Net::HTTPOK
      yield if block_given?

      format_for resp
    when Net::HTTPMovedPermanently, Net::HTTPMovedTemporarily, Net::HTTPFound
      yield if block_given?
      get resp.response["Location"]
    else
      raise Otomo::BadResponse, resp
    end
  end

  def format_for resp
    content = resp.header["Content-Type"]

    if content
      content = content.split(";")[0]
    end

    Otomo::FormatHandlers[content].process(resp)
  end


  def default_port
    case @scheme
    when "https"
      443
    else
      80
    end
  end

  end
end