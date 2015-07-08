module DSLink
    class DataHandler

        def initialize
            @request_handler = DSLink::RequestHandler
            @response_handler = DSLink::ResponseHandler
        end

        def handle_data(data)
            @request_handler.handle_requests(data['requests']) if data['requests']
            @response_handler.handle_responses(data['responses']) if data['responses']
        end

        def send_responses
            @request_handler.send_responses
        end

    end
end