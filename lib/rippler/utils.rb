module Rippler

  # Utility methods to be included
  module Utils
    RIPPLE_TIME_OFFSET = 946684800 # Time.utc(2000,1,1,0,0,0).to_i

    def Time(seconds)
      Time.at(RIPPLE_TIME_OFFSET + seconds.to_i)
    end

    def Money(data)
      Rippler::Money.new(data)
    end

    def Account(data)
      Rippler::Account.new(data)
    end
  end
end
