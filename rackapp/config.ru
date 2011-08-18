require 'rubygems'
require 'camping'

### Begin Camping application ###
Camping.goes :Poetify

# require 'poem'

module Nuts::Controllers
    class Index < R '/'
      def get
        $:
      end
    end
  end

run Poetify
