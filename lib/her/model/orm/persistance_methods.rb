module Her
  module Model
    module ORM
      module PersistanceMethods
        extend ActiveSupport::Concern

        def new?
          !@data.include?(:id)
        end
        alias_method :new_record?, :new?

        def persisted?
          !new_record?
        end

        def destroyed?
          @metadata.include?(:destroyed) && @metadata[:destroyed] == true
        end
      end
    end
  end
end
