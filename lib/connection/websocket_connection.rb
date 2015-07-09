require 'json'

module DSLink
    class WebSocketConnection
        include Celluloid
        trap_exit :handle_exit

        attr_accessor :data_handler

        def initialize(handshake)
            @handshake = handshake
            @data_handler = DSLink::DataHandler.new
            @conn = nil
            @ping_count = 1
        end

        def setup_timers
            @response_timer = every(@interval) do
                @response_timer.pause
                @data_handler.send_responses
                @response_timer.resume
            end
            @send_timer = after (50) do
                send_data({ ping: @ping_count })
                @ping_count += 1
            end
            @receive_timer = after (60) do
                DSLinkLogger.debug "WebSocket Closed due to inactivity"
                reconnect
            end
        end

        def teardown_timers
            @response_timer.cancel  unless @response_timer.nil?
            @send_timer.cancel      unless @send_timer.nil?
            @receive_timer.cancel   unless @receive_timer.nil?
            @response_timer = nil
            @send_timer = nil
            @receive_timer = nil
        end

        def connect
            teardown_timers
            @conn.shutdown  if @conn.respond_to? :shutdown
            @conn.terminate if @conn.respond_to? :terminate
            if @handshake.do_handshake
                @interval = (@handshake.interval || 100).to_f / 1000.0
                @ws_uri = @handshake.auth_url
                @conn = DSLink::WebSocketClient.new(@ws_uri, current_actor)
                if @conn.start
                    setup_timers
                end
            else
                sleep 1
                connect
            end
        end

        def reconnect
            teardown_timers
            begin
                @conn.shutdown  if @conn.respond_to? :shutdown
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
                @reconnect_timer = [@reconnect_timer * 2, 60].min
                DSLinkLogger.debug "Reconnect failed trying again in #{@reconnect_timer} seconds"
                sleep @reconnect_timer
                reconnect
            end
        end

        def on_open
            DSLinkLogger.debug "WebSocket Connected"
            @reconnect_timer = 1
            setup_timers
        end

        def on_message(msg)
            receive_data(msg) if msg.is_a? String
        end

        def on_close(code, reason)
            teardown_timers
            DSLinkLogger.debug "Websocket Disconnected #{code}, #{reason}"
            connect
        end

        def receive_data(data)
            DSLinkLogger.debug 'onData: ' + data.to_s
            data = JSON.parse(data)
            @salt = data['salt'] if data['salt']
            @data_handler.handle_data(data)
            @receive_timer.reset
        end

        def send_data(data)
            unless @conn.nil?
                data = data.to_json
                DSLinkLogger.debug 'send: ' + data
                @conn.text(data)
            end
            @send_timer.reset
        end

        # def handle_exit(actor, reason)
        #     puts 'HANDLE'
        #     puts actor
        #     puts reason
        # end

        def shutdown_connection
            teardown_timers
            @conn.shutdown  if @conn.respond_to? :shutdown
            @conn.terminate if @conn.respond_to? :terminate
            @conn = nil
        end


    end
end