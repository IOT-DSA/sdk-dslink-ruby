module DSLink
    class Request

        attr_reader :response


        def initialize(request)
            @response = nil
            @request = request
            @rid = request['rid']
            @method = request['method']
            process
        end

        def has_response?
            (@response.is_a? DSLink::Response)
        end

        def process
            if @method == 'list'
                do_list
            elsif @method == 'subscribe'
                do_subscribe
            elsif @method == 'unsubscribe'
                do_unsubscribe
            elsif @method == 'invoke'
                do_invoke
            elsif @method == 'set'
                do_set
            end
        end

        def do_set
            path = @request['path']
            permit = @request['permit']
            val = @request['value']
            node = DSLink::Link.instance.provider.get_node(path)
            node.value = val
        end


        def do_invoke
            path = @request['path']
            params = @request['params']
            node = DSLink::Link.instance.provider.get_node(path)
            node.invoke(params)
        end

        def do_subscribe
            paths = @request['paths']
            paths.each do |sub|
                DSLink::Link.instance.subscriptions.subscribe(sub['path'], sub['sid'])
            end
            @response = DSLink::Response.new({ rid: @rid, stream: 'closed' })
            DSLink::Response.flush
            DSLink::Link.instance.subscriptions.send_updates(paths.map { |s| s['sid'] })
        end

        def do_unsubscribe
            sids = @request['sids']
            sids.each do |sid|
                DSLink::Link.instance.subscriptions.unsubscribe(sid)
            end
            @response = DSLink::Response.new({ rid: @rid, stream: 'closed' })
            DSLink::Response.flush
        end


        def do_list
            path = @request['path']
            @response = DSLink::Response.new({ rid: @rid, stream: "open", updates: DSLink::Link.instance.provider.get_node(path).to_stream })
        end
    end
end