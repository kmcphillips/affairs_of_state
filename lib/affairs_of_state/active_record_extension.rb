# frozen_string_literal: true
module AffairsOfState
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    class_methods do
      def affairs_of_state(*statuses, column: :status, allow_blank: false, scopes: true, if: nil)
        raise ArgumentError.new("Affairs of State: cannot be invoked multiple times on the same model") if affairs_of_state_configs.any?

        config = AffairsOfState::Config.new(
          statuses: statuses,
          column: column,
          allow_blank: !!allow_blank,
          scopes: scopes,
          if: binding.local_variable_get(:if)
        )

        const_set(:STATUSES, config.statuses)

        config.statuses.each do |status|
          define_method("#{ status }?") do
            self.send(config.column) == status
          end

          define_method("#{ status }!") do
            self.send("#{ config.column }=", status)
            self.save
          end
        end

        validates(config.column, inclusion: { in: config.statuses, allow_blank: config.allow_blank }, if: config.if)

        if config.scopes
          config.statuses.each do |status|
            self.scope(status.to_sym, -> { where(config.column => status) })
          end
        end

        affairs_of_state_configs[config.column] = config

        include InstanceMethods
        extend SingletonMethods

        true
      end

      def affairs_of_state_configs
        @affairs_of_state_configs ||= {}
      end
    end

    module InstanceMethods
    end

    module SingletonMethods
      def statuses_for_select
        affairs_of_state_configs.values.first.statuses.map{ |s| [s.humanize, s] }
      end
    end
  end
end
