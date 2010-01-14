require 'forwardable'
require 'time'
require 'haml'

module Ww
  class StampSheet
    extend Forwardable
    def_delegator :@servlet, :requests

    def initialize(servlet)
      @servlet = servlet
    end

    def call(env)
      [200, {"Content-Type" => "text/html"}, template.render(self)]
    end

    private
    def template
      path = ::File.expand_path("sheet.html.haml", ::File.dirname(__FILE__))
      Haml::Engine.new(::File.read(path))
    end
  end
end

