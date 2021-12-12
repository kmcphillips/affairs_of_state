# frozen_string_literal: true
module AffairsOfState
  class Config
    attr_reader :statuses, :column, :allow_blank, :scopes, :if

    DISALLOWED_STATUSES = [ "new" ].freeze

    def initialize(statuses:, column:, allow_blank:, scopes:, if:)
      @column = column
      @allow_blank = !!allow_blank
      @scopes = !!scopes
      @if = binding.local_variable_get(:if)
      @statuses = statuses.flatten.map(&:to_s)
      @statuses.each do |status|
        raise ArgumentError.new("Affairs of State: '#{ status }' is not a valid status") if DISALLOWED_STATUSES.include?(status)
      end
    end
  end
end
