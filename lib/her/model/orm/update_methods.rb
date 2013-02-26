module Her
  module Model
    module ORM
      module UpdateMethods
        extend ActiveSupport::Concern

        # Update resource attribute
        #
        # @example Update resource attribute
        #   @user = User.find(1)
        #   # Fetched via GET "/users/1"
        #   @user.update_attributes(:fullname, "Tobias Fünke")
        #   # Called via PUT "/users/1"
        def update_attribute(attribute, value)
          send(attribute.to_s + '=', value)
          save
        end

        def update_attributes(attributes)
          self.data.merge!(attributes)
          save
        end

        def update_attributes!(attributes)
          self.data.merge!(attributes)
          save!
        end
      end
    end
  end
end
