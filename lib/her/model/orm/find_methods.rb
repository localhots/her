module Her
  module Model
    module ORM
      module FindMethods
        extend ActiveSupport::Concern

        module ClassMethods
          # Fetch specific resource(s) by their ID
          #
          # @example
          #   @user = User.find(1)
          #   # Fetched via GET "/users/1"
          #
          # @example
          #   @users = User.find([1, 2])
          #   # Fetched via GET "/users/1" and GET "/users/2"
          def find(*ids)
            params = ids.last.is_a?(Hash) ? ids.pop : {}
            prepared_ids = ids.flatten.compact.uniq
            results = prepared_ids.map do |id|
              resource = nil
              request(params.merge(_method: :get, _path: build_request_path(params.merge(id: id)))) do |parsed_data|
                resource = new(parse(parsed_data[:data]).merge _metadata: parsed_data[:data], _errors: parsed_data[:errors])
                wrap_in_hooks(resource, :find)
              end
              resource
            end
            if ids.length > 1 || ids.first.kind_of?(Array)
              raise RecordNotFound.one(self.class, ids) if results.nil?
              results
            else
              raise RecordNotFound.some(self.class, ids, results.length, prepared_ids.length) if results.length != prepared_ids.length
              results.first
            end
          end

          def find_by_id(id)
            find(id)
          rescue RecordNotFound
            nil
          end
        end
      end
    end
  end
end
