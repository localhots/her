module Her
  class RecordInvalid < Exception
    def initialize(errors)
      message = errors.map{ |field, message| [field, message].join(' ') }.join(', ')
      super(message)
    end
  end
end
