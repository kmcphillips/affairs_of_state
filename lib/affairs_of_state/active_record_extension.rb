# frozen_string_literal: true
module AffairsOfState
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    class_methods do
      def affairs_of_state(*statuses, column: :status, allow_blank: false, scopes: true, if: nil, prefix: nil)
        # config object that defines behaviour
        config = AffairsOfState::Config.new(
          statuses: statuses,
          prefix: prefix,
          column: column,
          allow_blank: !!allow_blank,
          scopes: scopes,
          if: binding.local_variable_get(:if)
        )

        # check for conflicts with existing calls
        raise ArgumentError, "Affairs of State: #{ self } has already been called on `#{ config.column }`" if affairs_of_state_configs[config.column]
        statuses_and_methods = affairs_of_state_configs.values.map(&:methods_for_statuses).map { |m| m.map{ |(k, v)| [k, v] } }.flatten
        overlapping_statuses = statuses_and_methods & config.methods_for_statuses.map{ |k, v| [k, v] }.flatten
        raise ArgumentError, "Affairs of State: #{ self } already has a status #{ overlapping_statuses }" if overlapping_statuses.any?

        # status methods
        config.methods_for_statuses.each do |status, method_name|
          define_method("#{ method_name }?") do
            self.send(config.column) == status
          end

          define_method("#{ method_name }!") do
            self.send("#{ config.column }=", status)
            self.save
          end
        end

        # scopes
        if config.scopes
          config.methods_for_statuses.each do |status, method_name|
            self.scope(method_name.to_sym, -> { where(config.column => status) })
          end
        end

        # column validation
        validates(config.column, inclusion: { in: config.statuses, allow_blank: config.allow_blank }, if: config.if)

        # cache the config on the object
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
      def statuses_for_select(column=nil)
        statuses(column).map{ |s| [s.humanize, s] }
      end

      def statuses(column=nil)
        if !column && affairs_of_state_configs.length == 1
          affairs_of_state_configs.values.first.statuses
        elsif !column && affairs_of_state_configs.length > 1
          raise ArgumentError, "column is required"
        elsif column
          affairs_of_state_configs[column.to_sym]&.statuses
        end
      end
    end
  end
end
