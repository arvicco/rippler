
module Rippler
  class Transaction
    def initialize data # data hash
      @data = data
    end

    def to_s
      @data["tx"]
    end
  end
end
