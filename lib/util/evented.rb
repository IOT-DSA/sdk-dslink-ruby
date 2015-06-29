module DSLink
    module Evented

        def on(event, &block)
            @__events ||= {}
            @__events[event] ||= []
            @__events[event] << block
        end

        def off(event)
            @__events.delete(event) if @__events[event]
        end

        def fire_event(event, data)
            return unless @__events && @__events[event]
            @__events[event].each do |block|
                block.call(data)
            end
        end
    end
end