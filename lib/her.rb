require 'her/version'

require 'multi_json'
require 'faraday'
require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext/hash'

require 'her/exceptions/exception'
require 'her/exceptions/record_invalid'
require 'her/exceptions/record_not_found'

require 'her/model'
require 'her/relation'
require 'her/api'
require 'her/middleware'
require 'her/errors'
require 'her/collection'
require 'her/paginated_collection'
require 'her/base'

module Her
end
