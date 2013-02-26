module Her
  class Relation
    def initialize(model)
      @model = model
      @conditions = []
      @group_conditions = []
      @order_conditions = []
      @limit_value = nil
      @offset_value = nil
      @do_paginate = false
      @do_count = false
    end

    def where(*args)
      args = args.first if args.first.is_a?(Hash)
      @conditions.push(args)
      self
    end

    def group(*args)
      @group_conditions += args
      self
    end

    def order(*args)
      @order_conditions += args
      self
    end

    def limit(value)
      @limit_value = value
      self
    end

    def offset(value)
      @offset_value = value
      self
    end

    def all
      with_response do |data|
        @model.new_collection(data)
      end
    end

    def count
      @do_count = true
      with_response do |data|
        data.first
      end
    end

    def first
      order('id asc').limit(1)
      all.first if all.respond_to?(:first)
    end

    def last
      order('id desc').limit(1)
      all.first if all.respond_to?(:first)
    end

    def paginate(page = 1, per_page = 20)
      @do_paginate = true
      offset((page - 1) * per_page).limit(per_page)
    end

  private

    def with_response
      params = {}
      params[:vodka_special_where] = @conditions unless @conditions.empty?
      params[:vodka_special_group] = @group_conditions unless @group_conditions.empty?
      params[:vodka_special_order] = @order_conditions unless @order_conditions.empty?
      params[:vodka_special_limit] = @limit_value unless @limit_value.nil?
      params[:vodka_special_offset] = @offset_value unless @offset_value.nil?
      params[:vodka_special_paginate] = 1 if @do_paginate
      params[:vodka_special_count] = 1 if @do_count

      @model.request(params.merge(_method: :get, _path: @model.build_request_path(params))) do |parsed_data|
        yield parsed_data if block_given?
      end
    end
  end
end
