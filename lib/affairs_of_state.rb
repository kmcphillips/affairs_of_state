require "active_support"
require "active_support/concern"
require "active_record"

require "affairs_of_state/version"
require "affairs_of_state/config"

module AffairsOfState
  extend ActiveSupport::Concern

  class_methods do
    def affairs_of_state(*statuses, column: :status, allow_blank: false, scopes: true, if: nil)
      raise ArgumentError.new("Affairs of State: cannot be invoked multiple times on the same model") if @affairs_of_state_config

      affairs_of_state_config.statuses = statuses
      affairs_of_state_config.column = column
      affairs_of_state_config.allow_blank = allow_blank
      affairs_of_state_config.scopes = scopes
      affairs_of_state_config.if = binding.local_variable_get(:if)

      const_set(:STATUSES, affairs_of_state_config.statuses)

      affairs_of_state_config.statuses.each do |status|
        define_method("#{ status }?") do
          self.send(self.class.affairs_of_state_config.column) == status
        end

        define_method("#{ status }!") do
          self.send("#{ self.class.affairs_of_state_config.column }=", status)
          self.save
        end
      end

      validates(affairs_of_state_config.column, inclusion: { in: affairs_of_state_config.statuses, allow_blank: affairs_of_state_config.allow_blank }, if: affairs_of_state_config.if)

      if affairs_of_state_config.scopes
        affairs_of_state_config.statuses.each do |status|
          self.scope(status.to_sym, -> { where(affairs_of_state_config.column => status) })
        end
      end

      include InstanceMethods
      extend SingletonMethods

      true
    end

    def affairs_of_state_config
      @affairs_of_state_config ||= AffairsOfState::Config.new
    end
  end

  module InstanceMethods
  end

  module SingletonMethods
    def statuses_for_select
      affairs_of_state_config.statuses.map{ |s| [s.humanize, s] }
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::Base.send :include, AffairsOfState
end
