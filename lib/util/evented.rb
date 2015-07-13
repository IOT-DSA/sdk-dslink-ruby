require 'pp'
module DSLink
    module Evented
        include Celluloid

        def on(event, id, &block)
            @__events ||= {}
            @__events[event] ||= []
            @__events[event] << { id: id, cb: block }
        end

        def off(event, id)
            @__events[event].delete_if { |evt| evt[:id] == id }
        end

        def fire_event(event, data)
            return unless @__events && @__events[event]
            @__events[event].each do |evt|
                evt[:cb].call(data)
            end
        end
    end
end