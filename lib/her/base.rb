module Her
  class Base # In case you prefer inheritance over mixins
    include Model
    include ActiveModel::Conversion if defined?(ActiveModel)
    include ActiveModel::AttributeMethods if defined?(ActiveModel)
    extend ActiveModel::Naming if defined?(ActiveModel)

    class << self
      def inherited(klass)
        klass.root_element(klass.name.demodulize.underscore)
        klass.collection_path(klass.root_element.pluralize)
        klass.resource_path([klass.collection_path, '/:id'].join)
        klass.uses_api(Her::API.default_api)
      end
    end
  end
end
