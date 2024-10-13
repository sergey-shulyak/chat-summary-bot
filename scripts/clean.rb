# frozen_string_literal: true

require 'dotenv/load'

require_relative 'lib/utils/time_utils'
require_relative 'lib/db'

db = DB.new(ENV.fetch('DB_NAME'))

db.clean_all!
