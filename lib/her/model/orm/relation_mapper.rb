module Her
  module Model
    module ORM
      module RelationMapper
        extend ActiveSupport::Concern

        module ClassMethods
          %w[ where group order limit offset all count first last paginate ].each do |name|
            define_method(name) do |*args|
              to_relation.send(name, *args)
            end
          end

          def to_relation
            ::Her::Relation.new(self)
          end
        end
      end
    end
  end
end
