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

    def timestring
      if tx
        "#{Time(tx['date']).strftime("%Y-%m-%d %H:%M:%S")} "
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
          get = Money(tx['TakerGets'])
          pay = Money(tx['TakerPays'])
          "OFR #{Account(tx['Account'])} ##{tx['Sequence']} offers " +
            "#{get} for #{pay} (#{get.rate(pay)})"
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

  def <=> other
    timestring <=> other.timestring
  end
end
