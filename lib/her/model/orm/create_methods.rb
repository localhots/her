module Her
  module Model
    module ORM
      module CreateMethods
        extend ActiveSupport::Concern

        module ClassMethods
          # Create a resource and return it
          #
          # @example
          #   @user = User.create({ fullname: "Tobias Fünke" })
          #   # Called via POST "/users/1"
          def create(params = {})
            new(params).save
          end

          def create!(params = {})
            resource = create(params)
            raise RecordInvalid.new(resource.errors) unless resource.errors.empty?

            resource
          end
        end
      end
    end
  end
end
