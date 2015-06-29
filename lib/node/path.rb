module DSLink
    class Path
        def initialize(path)
            @path = path
        end

        def parent
            idx = @path.rindex('/') - 1
            DSLink::Path.new @path[0..idx]
        end

        def path
            @path
        end
    end
end