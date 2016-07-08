require "affairs_of_state/version"

require "active_support"
require "active_support/concern"
require "active_record"

module AffairsOfState
  extend ActiveSupport::Concern

  class_methods do
    def affairs_of_state(*statuses, column: :status, allow_blank: false, scopes: true, if: nil)
      raise ArgumentError.new("Affairs of State: cannot be invoked multiple times on the same model") if @_statuses

      @_status_options = { column: column, allow_blank: allow_blank, scopes: scopes, if: binding.local_variable_get(:if) }
      @_statuses = statuses.flatten.map(&:to_s)

      const_set("STATUSES", @_statuses)

      validates(@_status_options[:column], inclusion: { in: @_statuses, allow_blank: @_status_options[:allow_blank] }, if: @_status_options[:if])

      if @_status_options[:scopes]
        @_statuses.each do |status|
          raise ArgumentError.new("Affairs of State: '#{ status }' is not a valid status") unless valid_status?(status)
          self.scope status.to_sym, -> { where(@_status_options[:column] => status.to_s) }
        end
      end

      include InstanceMethods
      extend SingletonMethods

      true
    end

    private

    def valid_status?(status)
      ![:new].include?(status.to_sym)
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
          self.send("#{ self.class.instance_variable_get('@_status_options')[:column] }=", method.to_s.gsub(/\!$/, ""))
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
      @_statuses.map{ |s| [s.humanize, s] }
    end
  end

end


ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::Base.send :include, AffairsOfState
end
