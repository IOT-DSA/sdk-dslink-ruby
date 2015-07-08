require 'time'
require File.join(File.dirname(__FILE__), '..', 'util', 'evented')

module DSLink
    class Node
        include DSLink::Evented

        attr_accessor :config, :attributes, :parent

        attr_reader :children, :name, :value, :path, :value_updated_at

        @@nodes = {}

        def self.get_node(path)
            @@nodes[path]
        end

        def initialize(path, tree)
            @value = nil
            @name = path.split('/').last
            @parent = nil
            @children = []
            if tree['$type']
                @value = DSLink::Value.new tree['$type']
            end
            @config = { '$is' => 'node' }
            @attributes = {}
            @@nodes[path] = self
            @path = path
            build path, tree
        end

        def add_child(path, tree)
            if tree['$is']
                child = provider.profile(tree['$is']).new path, tree
            else
                child = DSLink::Node.new path, tree
            end
            # child.parent = self
            @children << child
            child
        end

        # Retrieves child specfied by name from Node's children
        #
        # @param name [String]
        # @return [Node, nil] child node or nil if child not found.
        def get_child(name)
            @children.detect { |c| c.name == name }
        end

        def remove_child(child)
        end


        def name
            @config['$name']
        end

        def name=(name)
            @config['$name'] = name
        end

        def type
            @config['$type']
        end

        def value=(val)
            begin    
                @value.value = val

            rescue
                DSLinkLogger.error "#{val} is not of type '#{@value.type}' for node: '#{@path}'"
            end
            fire_event 'update', val
        end


        def has_value?
            @value.is_a? DSLink::Value
        end

        def value
            @value.value || nil
        end

        def value_updated_at
            @value.updated_at
        end

        def to_stream
            out = @config.merge(@attributes).to_a
            @children.each do |child|
                val = child.has_value? ? { 'value' => child.value, 'ts' => child.value_updated_at.iso8601 } : {}
                out << [child.path.split('/').last, child.config.merge(child.attributes).merge(val)]
            end
            out
        end

        private

        def build(start_path, tree)
            start_path = '' if start_path == '/'
            tree.each do |key, val|
                if val.is_a? Hash
                    add_child "#{start_path}/#{key}", val
                else
                    add_property key, val
                end
            end
        end

        def provider
            DSLink::Link.instance.provider
        end

        def add_property(key, val)
            if key == '$type'
                @config['$type'] = val
            elsif key == '$name'
                @config['$name'] = val
                @name = val
            elsif key[0] == '$'
                @config[key] = val
            elsif key[0] == '@'
                @attributes[key] = val
            elsif key == '?value'
                self.value = val
            end
        end

    end
end