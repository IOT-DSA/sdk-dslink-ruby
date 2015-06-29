require 'pp'
module DSLink
    class NodeProvider

        attr_reader :root_node


        def initialize
            @is = {}
            @nodes = {}
        end

        def load(tree)
            @root_node = DSLink::Node.new '/', tree
        end


        def get_node(path)
            DSLink::Node.get_node(path)
        end

        def add_node(path, tree)
            p = DSLink::Path.new path
            get_node(p.parent.path).add_child path, tree
        end

        def remove_node(path)
        end

        def update_value(path, value)
            get_node(path).value = value
        end

        def get_value(path)

        end

        def save(file)
        end

        def profile(name)
            @is[name]
        end

        def is(name, obj)
            @is[name] = obj
        end

        def provider
            DSLink::Link.instance.provider
        end

    end
end