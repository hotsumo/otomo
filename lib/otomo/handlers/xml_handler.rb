require 'nokogiri'
module Otomo
  module Handlers
    class XmlHandler
      def process resp
        Nokogiri::XML(resp.body)
      end
    end
  end
end

Otomo::FormatHandlers["application/xml"] = Otomo::Handlers::XmlHandler.new