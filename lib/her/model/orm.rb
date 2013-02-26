module Her
  module Model
    # This module adds ORM-like capabilities to the model
    module ORM
      extend ActiveSupport::Concern
      include CreateMethods
      include DestroyMethods
      include FindMethods
      include SaveMethods
      include UpdateMethods
      include RelationMapper
      include ErrorMethods
      include ComparisonMethods
      include PersistanceMethods
      include SerializationMethods
      include FieldsDefinition

      attr_accessor :data, :metadata, :errors
      alias :attributes :data
      alias :attributes= :data=

      # Initialize a new object with data received from an HTTP request
      def initialize(params={})
        fields = self.class.instance_variable_defined?(:@fields) ? self.class.instance_variable_get(:@fields) : []
        @data = Hash[fields.map{ |field| [field, nil] }]
        @metadata = params.delete(:_metadata) || {}
        @errors = params.delete(:_errors) || {}

        # Use setter methods first, then translate attributes of relationships
        # into relationship instances, then merge the parsed_data into @data.
        unset_data = Her::Model::ORM.use_setter_methods(self, params)
        parsed_data = self.class.parse_relationships(unset_data)
        @data.update(parsed_data)
      end

      # Initialize a collection of resources
      # @private
      def self.initialize_collection(klass, parsed_data={})
        collection_data = parsed_data[:data].map do |item_data|
          resource = klass.new(klass.parse(item_data))
          klass.wrap_in_hooks(resource, :find)
          resource
        end

        collection_class = Her::Collection
        if parsed_data[:metadata].is_a?(Hash) && parsed_data[:metadata].has_key?(:current_page)
          collection_class = Her::PaginatedCollection
        end
        collection_class.new(collection_data, parsed_data[:metadata], parsed_data[:errors])
      end

      # Handles missing methods by routing them through @data
      # @private
      def method_missing(method, *args, &blk)
        if method.to_s.end_with?('=')
          @data[method.to_s.chomp('=').to_sym] = args.first
        elsif method.to_s.end_with?('?')
          @data.include?(method.to_s.chomp('?').to_sym)
        elsif @data.include?(method)
          @data[method]
        else
          super
        end
      end

      # Handles returning true for the cases handled by method_missing
      def respond_to?(method, include_private = false)
        method.to_s.end_with?('=') || method.to_s.end_with?('?') || @data.include?(method) || super
      end

      # Assign new data to an instance
      def assign_data(new_data)
        new_data = Her::Model::ORM.use_setter_methods(self, new_data)
        @data.update new_data
      end
      alias :assign_attributes :assign_data

      # Handles returning true for the accessible attributes
      def has_data?(attribute_name)
        @data.include?(attribute_name)
      end

      # Handles returning attribute value from data
      def get_data(attribute_name)
        @data[attribute_name]
      end

      # Override the method to prevent from returning the object ID (in ruby-1.8.7)
      # @private
      def id
        @data[:id] || super
      end

      # Use setter methods of model for each key / value pair in params
      # Return key / value pairs for which no setter method was defined on the model
      # @private
      def self.use_setter_methods(model, params)
        setter_method_names = model.class.setter_method_names
        params.inject({}) do |memo, (key, value)|
          setter_method = key.to_s + '='
          if setter_method_names.include?(setter_method)
            model.send(setter_method, value)
          else
            if key.is_a?(String)
              key = key.to_sym
            end
            memo[key] = value
          end
          memo
        end
      end

      module ClassMethods
        # Initialize a collection of resources with raw data from an HTTP request
        #
        # @param [Array] parsed_data
        def new_collection(parsed_data)
          Her::Model::ORM.initialize_collection(self, parsed_data)
        end

        # Parse data before assigning it to a resource
        #
        # @param [Hash] data
        def parse(data)
          if parse_root_in_json
            parse_root_in_json == true ? data[root_element.to_sym] : data[parse_root_in_json]
          else
            data
          end
        end

        # Save an existing resource and return it
        #
        # @example
        #   @user = User.save_existing(1, { fullname: "Tobias Fünke" })
        #   # Called via PUT "/users/1"
        def save_existing(id, params)
          resource = new(params.merge(id: id))
          resource.save
          resource
        end

        # Destroy an existing resource
        #
        # @example
        #   User.destroy_existing(1)
        #   # Called via DELETE "/users/1"
        def destroy_existing(id, params={})
          request(params.merge(_method: :delete, _path: build_request_path(params.merge(id: id)))) do |parsed_data|
            new(parse(parsed_data[:data]))
          end
        end

        # @private
        def setter_method_names
          @setter_method_names ||= instance_methods.inject(Set.new) do |memo, method_name|
            memo << method_name.to_s if method_name.to_s.end_with?('=')
            memo
          end
        end

        # Return or change the value of `include_root_in_json`
        def include_root_in_json(value=nil)
          return @include_root_in_json if value.nil?
          @include_root_in_json = value
        end

        # Return or change the value of `parse_root_in`
        def parse_root_in_json(value=nil)
          return @parse_root_in_json if value.nil?
          @parse_root_in_json = value
        end
      end
    end
  end
end
