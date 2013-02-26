module Her
  module Model
    module ORM
      module FieldsDefinition
        extend ActiveSupport::Concern

        module ClassMethods
          def fields(*fields)
            self.instance_variable_set(:@fields, fields)
          end
        end
      end
    end
  end
end
