module AffairsOfState
  class Config
    attr_accessor :column, :allow_blank, :scopes, :if
    attr_reader :statuses

    def statuses=(val)
      @statuses = val.flatten.map(&:to_s)

      @statuses.each do |status|
        raise ArgumentError.new("Affairs of State: '#{ status }' is not a valid status") if ["new"].include?(status)
      end

      @statuses
    end
  end
end
