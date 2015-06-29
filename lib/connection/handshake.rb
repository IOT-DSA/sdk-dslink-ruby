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

        @version = '1.0.1'

        def initialize(opts)
            @broker_uri = opts[:broker_uri]     || 'http://localhost:8080/conn'
            @link_name  = opts[:link_name]      || 'ruby-dslink-'
            @requester  = opts[:is_requester]   || false
            @responder  = opts[:is_responder]   || false
            @auth_url   = nil
            do_handshake
        end

        def responder?
            @responder
        end

        def requester?
            @requester
        end


        # Private Methods
        private

        def do_handshake
            @ecdh = OpenSSL::PKey::EC.new('prime256v1')
            @ecdh.generate_key

            binary_pub_key          = hex_to_bin(@ecdh.public_key.to_bn.to_s(16))
            digest                  = OpenSSL::Digest::SHA256.new(binary_pub_key).digest
            encoded_binary_pub_key  = Base64.urlsafe_encode64(binary_pub_key).sub('=', '')
            encoded_pub_key         = Base64.urlsafe_encode64(digest).sub('=', '')

            @ds_id  = "#{@link_name}-#{encoded_pub_key}"
            @uri    = URI.parse("#{@broker_uri}?dsId=#{ds_id}")

            http    = Net::HTTP.new(uri.host, uri.port)
            opts    = { publicKey: encoded_binary_pub_key, isRequester: requester?, isResponder: responder?, version: version }.to_json
            headers = {
                        'Content-Type'      => "application/json",
                        'Accept-Encoding'   => "gzip,deflate",
                        'Accept'            => "application/json"
                      }
            response        = http.post("#{uri.path}?#{uri.query}", opts, headers)
            server_response = JSON.parse(response.body)

            @interval = server_response['updateInterval'] || 100


            temp_key     = OpenSSL::BN.new(Base64.urlsafe_decode64(server_response['tempKey'] + '='), 2)
            auth         = server_response['salt'].encode("UTF-8") + @ecdh.dh_compute_key(OpenSSL::PKey::EC::Point.new(@ecdh.group, temp_key))
            auth_digest  = OpenSSL::Digest::SHA256.new(auth).digest
            encoded_auth = Base64.urlsafe_encode64(auth_digest).sub('=', '')

            @auth_url    = "ws://#{uri.host}:#{uri.port}#{server_response['wsUri']}?dsId=#{ds_id}&auth=#{encoded_auth}"
            DSLinkLogger.debug 'Generated auth url: ' + @auth_url
        end
        
        def hex_to_bin(s)
          s.scan(/../).map { |x| x.hex }.pack('c*')
        end


    end
end


