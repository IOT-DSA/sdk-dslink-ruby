module DSLink
    class Response

        @@queue = []

        attr_accessor :rid, :stream, :updates

        def initialize(response)
            @rid = response[:rid] || nil
            @stream = response[:stream] || nil
            @updates = response[:updates] || nil
            @@queue << self
        end

        def to_stream
            h = {}
            h[:rid] = @rid
            h[:stream] = @stream unless @stream.nil?
            h[:updates] = @updates unless @updates.nil?
            h
        end

        def self.flush
            if @@queue.length > 0
                DSLink::Link.instance.conn.send_data({ responses: @@queue.uniq.map { |r| r.to_stream } })
                @@queue = []
            end
        end

    end
end