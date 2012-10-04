require 'hash_engine/actions'
require 'hash_engine/fetchers'
require 'hash_engine/format'
require 'hash_engine/extract'
require 'hash_engine/transform'
require 'hash_engine/csv_parse'

module HashEngine
  extend Actions
  extend Fetchers
  extend Format
  extend Extract
  extend Transform
  extend CSVParse
  extend self

  VERSION = '0.2.4'
end
