require 'forwardable'
require 'celluloid'
require 'celluloid/io'
require 'websocket/driver'

module DSLink
  class WebSocketClient
    include Celluloid
    include Celluloid::IO
    extend Forwardable

    attr_reader :url

    def initialize(url, handler)
      @url = url
      @handler = handler
    end
    

    def start
      uri = URI.parse(@url)
      port = uri.port || (uri.scheme == "ws" ? 80 : 443)
      begin
        @socket = Celluloid::IO::TCPSocket.new(uri.host, port)
        @client = ::WebSocket::Driver.client(self)
      rescue
        return false
      end
      async.run
      true
    end

    def run
      @client.on('open') do |event|
        @handler.async.on_open if @handler.respond_to?(:on_open)
      end
      @client.on('message') do |event|
        @handler.async.on_message(event.data) if @handler.respond_to?(:on_message)
      end
      @client.on('close') do |event|
        @handler.async.on_close(event.code, event.reason) if @handler.respond_to?(:on_close)
      end

      @client.start

      loop do
        begin
          @client.parse(@socket.readpartial(1024))
        rescue EOFError
          break
        end
      end
    end

    def_delegators :@client, :text, :binary, :ping, :close, :protocol

    def write(buffer)
      @socket.write buffer
    end

    def shutdown
      @client.close if @client.respond_to? :close
      @socket.close if @socket.respond_to? :close
    end
  end
end


