require File.join(File.dirname(__FILE__), 'response')
module DSLink
    class ErrorResponse < DSLink::Response
        def initialize(response)
            super(response)
            @error = response[:error]
        end

        def to_stream
            h = super
            h[:error] = @error
            h
        end
    end
end