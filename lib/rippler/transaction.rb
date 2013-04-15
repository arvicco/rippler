module Rippler
  # Represents a single Ripple transaction
  class Transaction
    include Rippler::Utils
    include Comparable

    def initialize data # data Hash
      @data = data
    end

    # Pure transaction data, without metadata
    def tx
      @data['tx'] || @data['transaction']
    end

    def type
      self.tx['TransactionType']
    end

    def amount
      Money(self.tx['Amount'])
    end

    def from
      self.tx['Account']
    end

    def to
      self.tx['Destination']
    end

    def dt
      self.tx['DestinationTag']
    end

    def date
      Time(tx['date'])
    end

    def timestring
      if tx
        "#{self.date.strftime("%Y-%m-%d %H:%M:%S")} "
      end
    end

    def to_s
      if tx
        timestring +
        case tx["TransactionType"]
        when "Payment"
          "PAY #{Money(tx['Amount'])} #{Account(tx['Account'])} > #{Account(tx['Destination'])}"
        when "OfferCancel"
          "CAN #{Account(tx['Account'])} ##{tx['Sequence']}"
        when "OfferCreate"
          Offer(tx).to_s
        when "TrustSet"
          "TRS #{Money(tx['LimitAmount'])} #{Account(tx['Account'])}"
        else
          tx
        end
      else
        @data
      end
    end
  end

  # Sort transactions by their timestamps
  def <=> other
    timestring <=> other.timestring
  end
end
