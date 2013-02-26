module Her
  module Model
    module ORM
      module SerializationMethods
        extend ActiveSupport::Concern

        # Delegate to @data, allowing models to act correctly in code like:
        #     [ Model.find(1), Model.find(1) ].uniq # => [ Model.find(1) ]
        def hash
          @data.hash
        end

        # Convert into a hash of request parameters
        #
        # @example
        #   @user.to_params
        #   # => { id: 1, name: 'John Smith' }
        def to_params
          if self.class.include_root_in_json
            { (self.class.include_root_in_json == true ? self.class.root_element : self.class.include_root_in_json) => @data.dup }
          else
            @data.dup
          end
        end
      end
    end
  end
end
