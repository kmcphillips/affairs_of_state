# frozen_string_literal: true
require "affairs_of_state"

require "sqlite3"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run_when_matching :focus
  # config.raise_errors_for_deprecations!
end

# Create an AR model to test with
I18n.enforce_available_locales = false

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "#{File.expand_path(File.join(File.dirname(__FILE__), '..'))}/spec/db/test.sqlite3"
)

ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'pies'")
ActiveRecord::Base.connection.create_table(:pies) do |t|
  t.string :status
  t.string :super_status
  t.string :sentiment
end
