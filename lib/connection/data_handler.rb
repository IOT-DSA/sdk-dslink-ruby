module DSLink
    class DataHandler

        def initialize
        end

        def handle_data(data)
            handle_requests(data['requests']) if data['requests']
            handle_responses(data['responses']) if data['responses']
        end

        def handle_requests(requests)
            requests.each do |req|
                DSLink::Request.new(req)
            end
        end

        def send_responses
            DSLink::Response.flush
        end

    end
end