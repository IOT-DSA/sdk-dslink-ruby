module DSLink
    class RequestHandler

        @@response_queue = []

        def self.send_responses
            if @@response_queue.length > 0
                DSLink::Link.instance.conn.send_data({ responses: @@response_queue })
                @@response_queue = []
            end
        end

        def self.queue_response(resp)
            @@response_queue << resp
        end

        def initialize(request)
            @request = request
            @rid = request['rid']
            @method = request['method']
        end

        def process
            if @method == 'list'
                list
            elsif @method == 'subscribe'
                subscribe
            elsif @method == 'unsubscribe'
                unsubscribe
            elsif @method == 'invoke'
                invoke
            end
        end



        def invoke
            path = @request['path']
            params = @request['params']
            node = DSLink::Link.instance.provider.get_node(path)
            node.invoke(params)
        end

        def subscribe
            paths = @request['paths']
            paths.each do |sub|
                DSLink::Link.instance.subscriptions.subscribe(sub['path'], sub['sid'])
            end
            @@response_queue << { rid: @rid, stream: 'closed' }
            DSLink::RequestHandler.send_responses
            DSLink::Link.instance.subscriptions.send_updates(paths.map { |s| s['sid'] })
        end

        def unsubscribe
            sids = @request['sids']
            sids.each do |sid|
                DSLink::Link.instance.subscriptions.unsubscribe(sid)
            end
            @@response_queue << { rid: @rid, stream: 'closed' }
            DSLink::RequestHandler.send_responses
        end



        def list
            path = @request['path']
            @@response_queue << { rid: @rid, stream: "open", updates: DSLink::Link.instance.provider.get_node(path).to_stream }
        end

        def self.handle_requests(requests)
            requests.each do |req|
                self.new(req).process
            end
        end

    end
end