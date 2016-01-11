require 'json'

module Otomo
  module Handlers
    class JsonHandler
      def process resp
        JSON.parse(resp.body)
      end
    end
  end
end

Otomo::FormatHandlers["application/json"] = Otomo::Handlers::JsonHandler.new