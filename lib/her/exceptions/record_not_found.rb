module Her
  class RecordNotFound < Exception
    class << self
      def one(model, id)
        new("Couldn't find #{model.name} with id=#{id}")
      end

      def some(model, ids, found, looking_for)
        super("Couldn't find all #{model.name}s with IDs (#{ids.join(', ')}) (found #{found} results, but was looking for #{looking_for})")
      end
    end
  end
end
