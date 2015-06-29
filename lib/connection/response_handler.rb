module DSLink
    class ResponseHandler

        def initialize(response)

        end

        def process
        end

        def self.handle_responses(link, responses)
            responses.each do |resp|
                self.new(resp).process
            end
        end

    end
end