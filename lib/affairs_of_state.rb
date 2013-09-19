require "affairs_of_state/version"

module AffairsOfState

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def affairs_of_state(*args)
      @_status_options = ({:column => :status, :allow_blank => false, :scopes => true, :if => nil}).merge(args.extract_options!)
      @_statuses = args.flatten.map(&:to_s)

      const_set("STATUSES", @_statuses)

      validates(@_status_options[:column], :inclusion => {:in => @_statuses, :allow_blank => @_status_options[:allow_blank]}, :if => @_status_options[:if])

      if @_status_options[:scopes]
        @_statuses.each do |status|
          scope status.to_sym, -> { where(@_status_options[:column] => status.to_s) }
        end
      end

      include InstanceMethods
      extend SingletonMethods
      true
    end
  end

  module InstanceMethods
    def method_missing(method, *args)
      if self.class::STATUSES.map{|s| "#{s}?".to_sym }.include?(method)
        self.class.send(:define_method, method) do
          self.status == method.to_s.gsub(/\?$/, "")
        end

        send method

      elsif self.class::STATUSES.map{|s| "#{s}!".to_sym }.include?(method)
        self.class.send(:define_method, method) do
          self.send("#{self.class.instance_variable_get('@_status_options')[:column]}=", method.to_s.gsub(/\!$/, ""))
          self.save
        end

        send method
      else
        super
      end
    end
  end

  module SingletonMethods
    def statuses_for_select
      @_statuses.map{|s| [s.humanize, s]}
    end
  end

end

ActiveRecord::Base.send :include, AffairsOfState
