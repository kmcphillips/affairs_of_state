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
    def method_missing(method, *args)
      if self.class::STATUSES.map{ |s| "#{ s }?".to_sym }.include?(method)
        self.class.send(:define_method, method) do
          self.status == method.to_s.gsub(/\?$/, "")
        end

        send(method)

      elsif self.class::STATUSES.map{ |s| "#{ s }!".to_sym }.include?(method)
        self.class.send(:define_method, method) do
          self.send("#{ self.class.affairs_of_state_config.column }=", method.to_s.gsub(/\!$/, ""))
          self.save
        end

        send(method)
      else
        super
      end
    end
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
