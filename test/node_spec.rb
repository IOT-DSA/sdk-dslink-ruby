# require 'spec_helper'

require_relative '../lib/dslink'


describe DSLink::Node do
    before :each do
        @node = DSLink::Node.new '/test', { '$name' => 'Test123', '$type' => 'string', '?value' => 'test value' }
    end

    describe '#value' do
        it 'should return the value of the node' do
            expect(@node.value).to eql 'test value'
        end
    end

    describe '#name' do
        it 'should return the name of the node' do
            expect(@node.name).to eql 'Test123'
        end
    end

    describe '#get_child' do
        before :each do
            @c = []
            @node = DSLink::Node.new '/test', { '$name' => 'Test123', '$type' => 'string', '?value' => 'test value' }
            (0..3).each do |i|
                @c << @node.add_child("/test/child-#{i}", { '$name' => "Child#{i}", '$type' => 'string', '?value' => 'test value' })
            end
        end
        
        it 'should return child specified by name' do
            expect(@node.get_child('Child0')).to eql(@c[0])
            expect(@node.get_child('Child1')).to eql(@c[1])
            expect(@node.get_child('Child2')).to eql(@c[2])
        end
        it 'should return nil if child does not exist' do
            expect(@node.get_child('Child4')).to eql(nil)
        end
    end

end