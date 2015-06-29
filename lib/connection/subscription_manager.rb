require 'time'

module DSLink
    class SubscriptionManager

        def initialize
            @subscriptions = {}
        end

        def subscribe(path, sid)
            DSLink::Link.instance.provider.get_node(path).on('update') do |val|
                send_update sid
            end
            @subscriptions[sid] = path
        end

        def unsubscribe(sid)
            DSLink::Link.instance.provider.get_node(@subscriptions[sid]).off('update')
            @subscriptions.delete sid
        end

        def send_updates(sids)
            u = []
            sids.each do |sid|
                u << update_json(sid)
            end
            DSLink::RequestHandler.queue_response({ rid: 0, updates: u })
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