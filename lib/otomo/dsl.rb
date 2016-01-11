module Otomo
  class DSL
    attr_accessor :otomo

    def initialize otomo, &block
      @otomo = otomo
      otomo.connect
      if block.parameters.count==0
        instance_eval(&block)
      elsif block.parameters.count==1
        block.call(self)
      else
        raise ArgumentError, "The block should have zero or one parameter"
      end
    end

    def debug_mode!
      otomo.http.set_debug_output($stdout)
    end

    def raw_mode!
      otomo.raw_mode = true
    end

    def get page
      otomo.get(page)
    end

    def post page, data={}
      otomo.post(page, data)
    end

    def header
      otomo.header
    end

    def html_document string
      otomo.html_document(string)
    end

    def add_cookie k,v
      otomo.add_cookie k,v
    end

    def remove_cookie c
      otomo.remove_cookie c.to_s
    end

    def clear_cookies
      otomo.clear_cookies
    end
  end
end