module Otomo
  class BadResponse < RuntimeError
    attr_accessor :response

    def initialize response
      @response = response
      super("Server responded with a #{response.code} (#{response.class.name})")
    end
  end
end