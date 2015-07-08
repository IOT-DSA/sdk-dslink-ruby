require 'json'

module DSLink
    class WebSocketConnection
        include Celluloid
        trap_exit :handle_exit

        attr_accessor :data_handler

        def initialize(handshake)
            @handshake = handshake
            @data_handler = DSLink::DataHandler.new
            @send_timer = nil
            @receive_timer = nil
            @conn = nil
            @ping_count = 1
        end

        def connect
            @conn.shutdown if @conn.respond_to? :shutdown
            @conn.terminate if @conn.respond_to? :terminate
            if @handshake.do_handshake
                @interval = @handshake.interval
                @ws_uri = @handshake.auth_url
                @conn = DSLink::WebSocketClient.new(@ws_uri, current_actor)
                if @conn.start
                    every @interval do
                        @data_handler.send_responses
                    end
                end
            else
                sleep 1
                connect
            end
        end

        def reconnect
            begin
                @conn.shutdown if @conn.respond_to? :shutdown
                @conn.terminate if @conn.respond_to? :terminate
            rescue
                @conn = nil
            end
            DSLinkLogger.debug "Reconnecting...."
            @ws_uri = @handshake.generate_auth_url(@salt)
            @conn = DSLink::WebSocketClient.new(@ws_uri, current_actor)
            if @conn.start
                @reconnect_timer = 1
            else
                @reconnect_timer = @reconnect_timer * 2
                DSLinkLogger.debug "Reconnect failed trying again in #{@reconnect_timer} seconds"
                sleep @reconnect_timer
                reconnect
            end
        end

        def on_open
            DSLinkLogger.debug "WebSocket Connected"
            @reconnect_timer = 1
            # @cb.call if @cb
            @send_timer = after (50) do
                send_data({ ping: @ping_count })
                @ping_count += 1
            end
            @receive_timer = after (60) do
                DSLinkLogger.debug "WebSocket Closed due to inactivity"
                reconnect
            end
        end

        def on_message(msg)
            receive_data(msg) if msg.is_a? String
        end

        def on_close(code, reason)
            DSLinkLogger.debug "Websocket Disconnected #{code}, #{reason}"
            if code == 1002
                connect
            end
        end

        def receive_data(data)
            DSLinkLogger.debug 'onData: ' + data.to_s
            data = JSON.parse(data)
            @salt = data['salt'] if data['salt']
            @data_handler.handle_data(data)
            @receive_timer.reset
        end

        def send_data(data)
            data = data.to_json
            DSLinkLogger.debug 'send: ' + data
            @conn.text(data)
            @send_timer.reset
        end

        # def handle_exit(actor, reason)
        #     puts 'HANDLE'
        #     puts actor
        #     puts reason
        # end

        def shutdown_connection
            @conn.shutdown if @conn.respond_to? :shutdown
            @conn.terminate if @conn.respond_to? :terminate
            @conn = nil
        end


    end
end