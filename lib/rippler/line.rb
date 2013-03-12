module Rippler
  # Line is a relationship between 2 Ripple accounts. It may have limit and balance.
  class Line < OpenStruct
    include Rippler::Utils

    def to_s
      "Account: #{Account(account)} balance: #{balance}/#{currency}, limits: #{limit_peer}/#{limit}"
    end
  end
end
