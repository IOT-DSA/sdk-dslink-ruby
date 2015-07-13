require "net/http"
require "uri"
require 'openssl'
require 'securerandom'
require 'base64'
require 'digest/sha2'
require 'json'


module DSLink

    class Handshake

        attr_accessor :broker_uri, :link_name

        attr_reader :version, :ds_id, :uri, :auth_url, :interval

        @@version = '1.0.1'

        def initialize(opts)
            @broker_uri = opts[:broker_uri]     || 'http://localhost:8080/conn'
            @link_name  = opts[:link_name]      || 'ruby-dslink-'
            @requester  = opts[:is_requester]   || false
            @responder  = opts[:is_responder]   || false
            @auth_url   = nil
        end

        def responder?
            @responder
        end

        def requester?
            @requester
        end

        def generate_auth_url(salt = nil)
            auth_param = ''
            unless salt.nil?
                encoded_auth = generate_auth(salt)
                auth_param = "&auth=#{encoded_auth}"
            end
            @auth_url    = "ws://#{uri.host}:#{uri.port}#{@ws_uri}?dsId=#{ds_id}#{auth_param}"
        end

        def do_handshake
            begin
                @ecdh = OpenSSL::PKey::EC.new(Base64.urlsafe_decode64(File.read('.dslink.key')))
            rescue
                @ecdh = OpenSSL::PKey::EC.new('prime256v1')
                @ecdh.generate_key
            end

            binary_pub_key          = hex_to_bin(@ecdh.public_key.to_bn.to_s(16))
            digest                  = OpenSSL::Digest::SHA256.new(binary_pub_key).digest
            encoded_binary_pub_key  = Base64.urlsafe_encode64(binary_pub_key).sub('=', '')
            encoded_pub_key         = Base64.urlsafe_encode64(digest).sub('=', '')

            @ds_id  = "#{@link_name}-#{encoded_pub_key}"
            @uri    = URI.parse("#{@broker_uri}?dsId=#{ds_id}")

            http    = Net::HTTP.new(uri.host, uri.port)
            opts    = { publicKey: encoded_binary_pub_key, isRequester: requester?, isResponder: responder?, version: @@version }.to_json
            headers = {
                        'Content-Type'      => "application/json",
                        'Accept-Encoding'   => "gzip,deflate",
                        'Accept'            => "application/json"
                      }
            begin
                response        = http.post("#{uri.path}?#{uri.query}", opts, headers)
            rescue
                DSLinkLogger.error 'Could not connect'
                return false
            end
            server_response = JSON.parse(response.body)

            @interval = server_response['updateInterval'] || 100
            @ws_uri = server_response['wsUri']

            if server_response['tempKey']
                temp_key     = OpenSSL::BN.new(Base64.urlsafe_decode64(server_response['tempKey'] + '='), 2)
                @computed_key = @ecdh.dh_compute_key(OpenSSL::PKey::EC::Point.new(@ecdh.group, temp_key))
            end
            generate_auth_url(server_response['salt'])
            File.write('.dslink.key', Base64.urlsafe_encode64(@ecdh.to_der))
            DSLinkLogger.debug 'Generated auth url: ' + @auth_url
            true
        end

        # Private Methods
        private

        def generate_auth(salt)
            auth         = salt.encode("UTF-8") + @computed_key
            auth_digest  = OpenSSL::Digest::SHA256.new(auth).digest
            Base64.urlsafe_encode64(auth_digest).sub('=', '')
        end
        
        def hex_to_bin(s)
          s.scan(/../).map { |x| x.hex }.pack('c*')
        end


    end
end


