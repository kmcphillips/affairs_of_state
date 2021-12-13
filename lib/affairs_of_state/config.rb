# frozen_string_literal: true
module AffairsOfState
  class Config
    attr_reader :statuses, :column, :allow_blank, :scopes, :if, :methods_for_statuses

    DISALLOWED_STATUSES = [ "new" ].freeze

    def initialize(statuses:, column:, allow_blank:, scopes:, if:, prefix:)
      @column = column
      @allow_blank = !!allow_blank
      @scopes = !!scopes
      @if = binding.local_variable_get(:if)
      @prefix = prefix.presence
      @statuses = statuses.flatten.map(&:to_s)
      @methods_for_statuses = @statuses.to_h do |s|
        if @prefix
          [s.to_s, "#{ prefix }_#{ s }"]
        else
          [s.to_s, s.to_s]
        end
      end
      @statuses.each do |status|
        raise ArgumentError.new("Affairs of State: '#{ status }' is not a valid status") if DISALLOWED_STATUSES.include?(status)
      end
    end
  end
end
