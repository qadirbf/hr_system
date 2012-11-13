module ActionView
  module Helpers
    module UrlHelper

      alias :url_for_old :url_for

      def url_for(options = {})
        options ||= {}
        case options
          when Hash
            options[:format]||="php"
        end

        url_for_old options
      end

    end
  end
end
