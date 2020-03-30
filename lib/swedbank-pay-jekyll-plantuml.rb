require 'open3'
require "swedbank/pay/jekyll/plantuml/version"
require 'swedbank/pay/jekyll/plantuml/plantuml_converter'

module Swedbank
  module Pay
    module Jekyll
      module Plantuml
        class Error < StandardError; end
      end
    end
  end
end
