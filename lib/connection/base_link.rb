require 'celluloid/autostart'
module DSLink
    class BaseLink
        include Celluloid

        def initialize
            @link = DSLink::Link.instance
        end
    end
end