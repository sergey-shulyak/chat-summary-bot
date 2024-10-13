# frozen_string_literal: true

# Load libraries
require 'dotenv/load'
require 'sqlite3'
require 'openai'
require 'telegram/bot'

# Configure
require_relative 'config/openai'

# Load app
require_relative 'lib/utils/time_utils'
require_relative 'lib/db'
require_relative 'lib/gpt_client'
require_relative 'lib/bot'
require_relative 'models/message'
