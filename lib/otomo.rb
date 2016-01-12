require "otomo/version"

require 'otomo/dsl'
require 'otomo/robot'
require 'otomo/bad_response'
require 'otomo/user_agents'

require 'otomo/format_handlers'

require 'otomo/handlers/html_handler'
require 'otomo/handlers/json_handler'
require 'otomo/handlers/text_handler'
require 'otomo/handlers/xml_handler'

module Otomo

  def self.session path, opts={}, &block
    robot = Otomo::Robot.new path, opts
    dsl = Otomo::DSL.new(robot, &block)

    # Return the DSL return value.
    dsl.result
  end

  def self.url_encode name, obj
    case obj
    when Hash
      obj.map{|k,v| self.url_encode("#{name}[#{URI.encode_www_form_component(k)}]", v) }.join("&")
    when Array
      obj.map{|k| self.url_encode("#{name}[]", k)}.join("&")
    else
      "#{name}=#{URI.encode_www_form_component(obj.to_s)}"
    end
  end

  def self.hash_to_www_url_encoded hash
    hash.map do |k,v|
      self.url_encode(URI.encode_www_form_component(k), v)
    end.join("&")
  end

end

