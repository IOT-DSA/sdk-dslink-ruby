require 'time'

module DSLink
    class SubscriptionManager

        def initialize
            @subscriptions = {}
        end

        def subscribe(path, sid)
            DSLink::Link.instance.provider.get_node(path).on('update', '__subscription__') do |val|
                send_update sid
            end
            @subscriptions[sid] = path
        end

        def unsubscribe(sid)
            if @subscriptions[sid]
                DSLink::Link.instance.provider.get_node(@subscriptions[sid]).off('update', '__subscription__')
                @subscriptions.delete sid
            end
        end

        def send_updates(sids)
            u = []
            sids.each do |sid|
                u << update_json(sid)
            end
            DSLink::Response.new({ rid: 0, updates: u })
        end

        def update_json(sid)
            node = DSLink::Link.instance.provider.get_node(@subscriptions[sid])
            { 'sid' => sid, 'value' => node.value, 'ts' => node.value_updated_at.iso8601 }
        end

        def send_update(sid)
            send_updates [sid]
        end

    end
end