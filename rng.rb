require './lib/dslink'
require 'eventmachine'

link = DSLink::Link.instance

# class InvokableNode < DSLink::Node

#     def invoke(params)
#         provider.add_node('/test/again-again', {
#             '$type' => 'string',
#             '?value' => 'pleasesss'
#         })
#     end

# end



# link.provider.is('invokable_node', InvokableNode)

nodes = {}

(0..1000).each do |i|
    nodes["rng-#{i}"] = {
        '$name' => "RNG-#{i}",
        '$type' => 'number',
        '?value' => Random::rand
    }
end

link.provider.load(nodes);


link.connect do |success|
    (0..1000).each do |i|
        EM.add_periodic_timer(rand(0.2..1.5).round(2)) do
            link.provider.update_value("/rng-#{i}", Random::rand)
        end
    end
end