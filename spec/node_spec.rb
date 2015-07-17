require 'spec_helper'

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

    describe '#value=' do
        it 'should not change value if val is wrong type' do
            expect(@node.value).to eql 'test value'
            @node.value = 0
            expect(@node.value).to eql 'test value'
        end
    end

    describe '#to_stream' do 
        before :each do
            @node = DSLink::Node.new('/test', { 
                '$name' => 'Test123',
                '$type' => 'string',
                '?value' => 'test value',
                'child-node' => {
                    '$type' => 'number',
                    '?value' => 0
                }
            })
        end
        it 'should return a dsa friendly hash of its node structure' do
            expect(@node.to_stream).to eql([["$is", "node"], ["$name", "Test123"], ["$type", "string"], ["child-node", {"$is"=>"node", "$type"=>"number", "value"=>0, "ts"=>"#{@node.children[0].value_updated_at.iso8601}"}]])
        end
    end

    describe '#to_save_stream' do 
        before :each do
            @node = DSLink::Node.new('/test', { 
                '$name' => 'Test123',
                '$type' => 'string',
                '?value' => 'test value',
                'child-node' => {
                    '$type' => 'number',
                    '?value' => 0
                }
            })
        end
        it 'should return a dsa friendly hash of its node structure' do
            expect(@node.to_save_stream).to eql({"$is"=>"node", "$name"=>"Test123", "$type"=>"string", "?value"=>"test value", "ts"=>"#{@node.value_updated_at.iso8601}", "child-node"=>{"$is"=>"node", "$type"=>"number", "?value"=>0, "ts"=>"#{@node.children[0].value_updated_at.iso8601}"}})
        end
    end

    describe '#has_value?' do
        it 'should return true if node has a value' do
            expect(@node.has_value?).to eql true
        end

        it 'should return false if node has a no value' do
            @node = DSLink::Node.new '/test', { '$name' => 'Test123' }
            expect(@node.has_value?).to eql false
        end
    end

    describe '#type' do
        it 'should return the type of the node' do
            expect(@node.type).to eql 'string'
        end
    end

    describe '#name' do
        it 'should return the name of the node' do
            expect(@node.name).to eql 'Test123'
        end
    end

    describe '#name=' do
        it 'should set the name of the node' do
            @node.name = 'Test456'
            expect(@node.name).to eql 'Test456'
        end
    end

    describe '#get_child' do
        before :each do
            @c = []
            @node = DSLink::Node.new '/test', { '$name' => 'Test123', '$type' => 'string', '?value' => 'test value' }
            (0..3).each do |i|
                @c << @node.add_child("child-#{i}", { '$name' => "Child#{i}", '$type' => 'string', '?value' => 'test value' })
            end
        end
        
        it 'should return child specified by name' do
            expect(@node.get_child('Child0')).to equal(@c[0])
            expect(@node.get_child('Child1')).to equal(@c[1])
            expect(@node.get_child('Child2')).to equal(@c[2])
        end
        it 'should return nil if child does not exist' do
            expect(@node.get_child('Child4')).to equal(nil)
        end
    end

    describe '#add_child' do
        before :each do
            @c = []
            class TestLink < DSLink::BaseLink
                def link
                    @link
                end
            end
            @link = TestLink.new.link
            @node = @link.provider.create_node('/test', { '$name' => 'Test123', '$type' => 'string', '?value' => 'test value' })
        end
        
        it 'should add a generic child to node' do
            child = @node.add_child('Child0', { '$name' => "Child", '$type' => 'string', '?value' => 'test value' })
            expect(child).to equal(@node.children[0])
            expect(child.is_a?(DSLink::Node)).to eql(true)
        end

        it 'should add a profiled child to node' do
            class TestNode < DSLink::Node
                attr_reader :test_path
                def create(path, tree)
                    @test_path = path
                end
            end
            @link.provider.is('test_node', TestNode)
            child = @node.add_child('Child', { '@id' => 1, '$is' => 'test_node', '$name' => "Child", '$type' => 'string', '?value' => 'test value', 'subChild' => { '$type' => 'number', '?value' => 0} })
            expect(child).to equal(@node.children[0])
            expect(child.test_path).to eq('Child')
            expect(child.is_a?(TestNode)).to eq(true)
        end
    end

    describe 'permission map' do
        before :each do
            @c = []
            class TestLink < DSLink::BaseLink
                def link
                    @link
                end
            end
            @link = TestLink.new.link
            @node = @link.provider.create_node('/test', { '$name' => 'Test123', '$type' => 'string', '?value' => 'test value' })
        end
        it 'should have correct permission map' do
            class TestNode < DSLink::Node
                def permission_map
                    @@permission_map
                end
            end
            @link.provider.is('test_node', TestNode)
            child = @node.add_child('Child', { '$is' => 'test_node', '$name' => "Child", '$type' => 'string', '?value' => 'test value'})
            expect(child.permission_map).to eq({
                'none' => 0,
                'read' => 1,
                'write' => 2,
                'config' => 3,
                'never' => 4
            })

        end
    end

end