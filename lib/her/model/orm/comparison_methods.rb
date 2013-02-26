module Her
  module Model
    module ORM
      module ComparisonMethods
        extend ActiveSupport::Concern

        # Return `true` if the other object is also a Her::Model and has matching data
        def ==(other)
          other.is_a?(Her::Model) && @data == other.data
        end

        # Delegate to the == method
        def eql?(other)
          self == other
        end
      end
    end
  end
end

