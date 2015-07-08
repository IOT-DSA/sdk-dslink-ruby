module DSLink
    class DataHandler

        @@response_queue = []

        def initialize
        end

        def handle_data(data)
            handle_requests(data['requests']) if data['requests']
            handle_responses(data['responses']) if data['responses']
        end

        def handle_requests(requests)
            requests.each do |req|
                r = DSLink::Request.new(req)
                queue_response(r.response) if r.has_response?
            end
        end

        def queue_response(resp)
            @@response_queue << resp
        end

        def send_responses
            DSLink::Response.flush
        end

    end
end