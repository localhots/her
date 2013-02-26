module Her
  module Model
    module ORM
      module SaveMethods
        extend ActiveSupport::Concern

        # Save a resource
        #
        # @example Save a resource after fetching it
        #   @user = User.find(1)
        #   # Fetched via GET "/users/1"
        #   @user.fullname = "Tobias Fünke"
        #   @user.save
        #   # Called via PUT "/users/1"
        #
        # @example Save a new resource by creating it
        #   @user = User.new({ fullname: "Tobias Fünke" })
        #   @user.save
        #   # Called via POST "/users"
        def save
          create_or_update
        end

        def save!
          save
          raise RecordInvalid.new(self.errors) unless self.errors.empty?

          self
        end

        def create_or_update
          params = to_params
          resource = self

          if @data[:id]
            hooks = [:update, :save]
            method = :put
          else
            hooks = [:create, :save]
            method = :post
          end

          self.class.wrap_in_hooks(resource, *hooks) do |resource, klass|
            klass.request(params.merge(_method: method, _path: request_path)) do |parsed_data|
              self.data = self.class.parse(parsed_data[:data]) if parsed_data[:data].any?
              self.metadata = parsed_data[:metadata]
              self.errors = parsed_data[:errors]

              return false if self.errors.any?
            end
          end

          self
        end
      end
    end
  end
end
