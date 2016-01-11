module Otomo
  module FormatHandlers
    @handlers = {}

    class << self
      attr_accessor :handlers, :default_handler

      def [] type
        @handlers[type] || default_handler
      end

      def []= type, value
        @handlers[type] = value
      end
    end
  end
end
