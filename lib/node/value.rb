module DSLink
    class Value

        attr_reader :value, :updated_at

        

        def initialize(val_type, value = nil)
            @value = nil
            @val_types = %w(number int uint string bool enum map array dynamic)
            @updated_at = nil
            self.type = val_type
        end

        def type=(val_type)
            _type = nil
            @val_types.each do |t|
                if val_type == t
                    _type = val_type
                    break
                elsif t == 'enum' and val_type.match(/enum\[[^\]]+\]/) != nil
                    _type = val_type
                    break
                end
            end
            raise "'#{val_type}' is not a known Value type" if _type.nil?
            @type = _type
        end

        def type
            @type
        end

        def value=(val)
            if check_type val
                @value = val
                @updated_at = Time.now
            else
                raise "#{val} is not of type '#{@type}'"
            end
        end

        private

        def check_type(val)
            valid = false
            if @type.index('enum') == 0
                valid = @type.match(/enum\[([^\]]+)\]/).captures[0].split(',').include? val
            elsif @type == 'string'
                valid = val.is_a? String
            elsif @type == 'number'
                valid = (val.is_a?(Fixnum) || val.is_a?(Float))
            elsif @type == 'int'
                valid = val.is_a? Fixnum
            elsif @type == 'uint'
                valid = val.is_a? Fixnum && val >= 0
            elsif @type == 'bool'
                valid = (val.is_a?(TrueClass) || val.is_a?(FalseClass))
            elsif @type == 'map'
                valid = val.is_a? Hash
            elsif @type == 'array'
                valid = val.is_a? Array
            elsif @type == 'dynamic'
                valid = true
            end
            valid
        end

    end
end