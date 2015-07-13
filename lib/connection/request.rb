module DSLink
    class Request

        attr_reader :response


        def initialize(request)
            @request = request
            @rid = request['rid']
            @method = request['method']
            process
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
            permission = @request['permission'] || 'read'
            node = DSLink::Link.instance.provider.get_node(path)
            if node.has_permission? permission
                node.invoke(params)
            else
                error_hash = {
                    type: 'permissionDenied',
                    msg: 'Permission Denied'
                }
                DSLink::ErrorResponse.new({ rid: @rid, stream: 'closed', error: error_hash })
            end
        end

        def do_subscribe
            paths = @request['paths']
            paths.each do |sub|
                DSLink::Link.instance.subscriptions.subscribe(sub['path'], sub['sid'])
            end
            DSLink::Response.new({ rid: @rid, stream: 'closed' })
            DSLink::Link.instance.subscriptions.send_updates(paths.map { |s| s['sid'] })
        end

        def do_unsubscribe
            sids = @request['sids']
            sids.each do |sid|
                DSLink::Link.instance.subscriptions.unsubscribe(sid)
            end
            DSLink::Response.new({ rid: @rid, stream: 'closed' })
        end


        def do_list
            path = @request['path']
            DSLink::Response.new({ rid: @rid, stream: "open", updates: DSLink::Link.instance.provider.get_node(path).to_stream })
        end
    end
end