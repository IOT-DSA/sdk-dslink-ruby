require 'websocket-eventmachine-client'
require 'json'

module DSLink
    class WebSocketConnection

        attr_accessor :data_handler

        def initialize(ws_uri)
            @ws_uri = ws_uri
            @data_handler = DSLink::DataHandler.new
        end

        def connect(&block)
            @conn = nil


            @conn = WebSocket::EventMachine::Client.connect(:uri => @ws_uri)

            @conn.onopen do
                DSLinkLogger.debug "WebSocket Connected"
                block.call if block
            end

            @conn.onmessage do |msg, type|
                receive_data(msg)
            end

            @conn.onclose do |code, reason|
                DSLinkLogger.debug "Disconnected with status code: #{code}"
            end

            EM.add_periodic_timer(0.1) do
                @data_handler.send_responses
            end
        end

        def receive_data(data)
            DSLinkLogger.debug 'onData: ' + data
            @data_handler.handle_data(JSON.parse(data))
        end

        def send_data(data)
            data = data.to_json
            DSLinkLogger.debug 'send: ' + data
            @conn.send(data)
        end
    end
end