require 'slop'
require 'singleton'


module DSLink
    class Link
        include Singleton

        attr_reader :provider, :conn, :subscriptions

        def initialize
            @subscriptions = DSLink::SubscriptionManager.new
            opts = parse_opts
            @broker_uri = opts[:broker]
            @link_name = opts[:name]
            DSLinkLogger.level = opts[:log]
            @conn = nil
            @provider = DSLink::NodeProvider.new
        end

        def start(prov)
            self.provider = prov
            connect
            self
        end

        def provider=(prov)
            unless prov.kind_of? DSLink::NodeProvider
                raise 'provider Must be of type DSLink::NodeProvider'
            end
            @provider = prov
        end

        def parse_opts
            opts = Slop.parse do |o|
                o.string '-b', '--broker', 'Broker to connect to.', default: 'http://localhost:8080/conn'
                o.string '-n', '--name', 'Name of link.', default: 'ruby-dslink'
                o.string '-l', '--log', 'Loggin level [info|debug|warn|error|fatal].', default: 'info'
                o.on '--version', 'print the version' do
                  puts 'Ruby DSLink SDK ' + DSLink::VERSION
                      exit
                end
            end
            return opts

        end

        def connect(&block)
            @handshake = DSLink::Handshake.new broker_uri: @broker_uri, link_name: @link_name, is_responder: true, is_requester: false
            EM.run do
                start_link @handshake.auth_url, { interval: @handshake.interval }
                block.call
            end
        end

        def start_link(ws_uri)
            @conn = DSLink::WebSocketConnection.new(ws_uri)
            @conn.connect
        end


    end
end