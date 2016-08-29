require 'net/http'
require 'nokogiri'

module Otomo
  class Robot

    attr_accessor :scheme, :host, :port

    attr_accessor :cookies, :referer

    attr_reader :http

    def raw_mode=raw_mode; @raw_mode=raw_mode; end
    def raw_mode?; @raw_mode; end

    attr_accessor :header

    def initialize path, header={}
      @header = header
      @raw_mode = false

      if path.is_a?(String)
        uri = URI(path)
        @scheme = uri.scheme
        @host = uri.host
        @port = uri.port
      end
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
      @http = Net::HTTP.new(@host, port)
      @http.use_ssl = (@scheme == "https")
    end

    def full_path path
      if path =~ URI::regexp
        path
      else
        "#{@scheme}://#{@host}" + File.join("/", path)
      end
    end

    def html_document string
      Nokogiri::HTML(string)
    end

    def put path, data={}, opts={}
      request "PUT", path, data, opts
    end

    def patch path, data={}, opts={}
      request "PATCH", path, data, opts
    end

    def get path, data={}, opts={}
      path, query = get_query_path path
      request "GET", path + query_encoded_data(data, query),nil, opts
    end

    def delete path, data={}, opts={}
      path, query = get_query_path path
      request "DELETE", path + query_encoded_data(data, query), nil, opts
    end

    def request method, path, data={}, opts={}
      resp = http.send_request(method, path, data, prepare_headers)

      handle_response resp, opts do
        set_cookies resp.get_fields('set-cookie')
        @referer = full_path(path)
      end
    end

    def post path, data={}, opts={}
      if data.is_a?(Hash)
        data = Otomo.hash_to_www_url_encoded(data)
      end

      resp = http.post(File.join("/", path), data, prepare_headers)

      handle_response resp, opts do
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
        @cookies = Hash[ from_array.map{|elm| (elm.split("; ")[0].split("=",2))  }]
      end
    end

    def get_cookies
      if @cookies
        @cookies.map{|k,v| "#{k}=#{v}"}.join("; ")
      else
        nil
      end
    end

    def get_query_path path

      if path =~ /^http(s)?:\/\//
        path.gsub!(/http(s)?:\/\/[^\/]+/, "")
      end

      #if idx = path.index("?")
      #  [ path[0..idx-1],  path[idx+1..-1] ]
      #else
      path
      #end
    end

    def query_encoded_data data, initial=nil
      if data.empty?
        ""
      else
        "?" + [ initial, URI.hash_to_www_url_encoded(data) ].compact.join("&")
      end
    end

    def prepare_headers
      @header.merge({
        'Cookie' => get_cookies,
        'Referer' => referer
      }).reject{ |k,v| v.nil? || v.empty? }
    end

    def handle_response resp, opts={}

      if (opts[:allow_codes]||[]).map(&:to_s).includes?(resp.code)
        yield if block_given?
        format_for resp
      else
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


    end

    def format_for resp
      return resp if raw_mode?
      content = resp.header["Content-Type"]

      if content
        content = content.split(";")[0]
        Otomo::FormatHandlers[content].process(resp)
      else
        Otomo::FormatHandlers::default_handler.process(resp)
      end
    end
  end
end