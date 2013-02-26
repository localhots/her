module Her
  module Model
    module ORM
      module DestroyMethods
        extend ActiveSupport::Concern

        # Destroy a resource
        #
        # @example
        #   @user = User.find(1)
        #   @user.destroy
        #   # Called via DELETE "/users/1"
        def destroy
          resource = self
          self.class.wrap_in_hooks(resource, :destroy) do |resource, klass|
            klass.request(_method: :delete, _path: request_path) do |parsed_data|
              self.data = self.class.parse(parsed_data[:data])
              self.metadata = parsed_data[:metadata]
              self.errors = parsed_data[:errors]
            end
          end
          self
        end

        def delete
          resource = self
          self.class.wrap_in_hooks(resource, :destroy) do |resource, klass|
            klass.request({_method: :delete, _path: build_request_path(params.merge(soft: true))}) do |parsed_data|
              self.data = self.class.parse(parsed_data[:data])
              self.metadata = parsed_data[:metadata]
              self.errors = parsed_data[:errors]
            end
          end
          self
        end

        module ClassMethods
          def destroy(ids)
            is_array = ids.is_a?(Array)
            ids = Array(ids)
            collection = ids.map{ |id| new(id: id).destroy }
            collection = collection.first unless is_array
            collection
          end

          def delete(ids)
            Array(ids).map{ |id| new(id: id).delete }.count
          end
        end
      end
    end
  end
end
