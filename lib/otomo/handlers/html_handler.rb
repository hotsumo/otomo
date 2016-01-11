require 'nokogiri'
module Otomo
  module Handlers
    class HtmlHandler
      def process resp
        Nokogiri::HTML(resp.body)
      end
    end
  end
end

Otomo::FormatHandlers["text/html"] = Otomo::Handlers::HtmlHandler.new