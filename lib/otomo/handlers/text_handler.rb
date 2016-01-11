# Simple text handler returning the string value of the
# body of the request.
module Otomo
  module Handlers
    class TextHandler
      def process resp
        resp.body
      end
    end
  end
end

Otomo::FormatHandlers::default_handler = Otomo::Handlers::TextHandler.new