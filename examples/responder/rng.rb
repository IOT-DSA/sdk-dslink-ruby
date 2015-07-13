require '../../lib/dslink'

class InvokableNode < DSLink::Node
    def invoke(params)
        puts rand(params['min']..params['max'])
    end
end


class RNGLink < DSLink::BaseLink

    def initialize
        super
        @_timers = []
        @num = 5
        @nodes = {
            'settable-node' => {
                '$writable' => 'write',
                '$name' => 'Settable Node',
                '$type' => 'string',
                '?value' => 'Set Me!'
            },
            'invokable-node' => {
                '$name' => 'Range',
                '$is' => 'invokable_node',
                '$invokable' => 'read',
                '$params' => { 'min' => { type: 'number' }, 'max' => { type: 'number' } }
            }
        }
        (0..@num).each do |i|
            @nodes["rng-#{i}"] = {
                '$name' => "RNG-#{i}",
                '$type' => 'number',
                '?value' => Random::rand
            }
        end

        @link.provider.is('invokable_node', InvokableNode)

        @link.provider.load(@nodes)
        @link.connect
        start_timers
        @link.provider.get_node('/settable-node').on('update', 'setable') do |val|
            puts val
        end
    end

    def start_timers
        every(1) do
            (0..@num).each do |i|
                @link.provider.update_value("/rng-#{i}", Random::rand)
            end
        end
    end
end

RNGLink.run




