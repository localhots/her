module Her
  module Model
    module ORM
      module ErrorMethods
        extend ActiveSupport::Concern

        # Return `true` if a resource does not contain errors
        def valid?
          @errors.empty?
        end

        # Return `true` if a resource contains errors
        def invalid?
          @errors.any?
        end
      end
    end
  end
end
