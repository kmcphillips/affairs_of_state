# frozen_string_literal: true
require "active_support"
require "active_support/concern"
require "active_record"

require "affairs_of_state/version"
require "affairs_of_state/config"
require "affairs_of_state/active_record_extension"

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::Base.send :include, AffairsOfState::ActiveRecordExtension
end
