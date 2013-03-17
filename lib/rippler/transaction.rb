module Rippler
  # Represents a single Ripple transaction
  class Transaction
    include Rippler::Utils

    def initialize data # data Hash
      @data = data
    end

    def to_s
      tx = @data['tx'] || @data['transaction']
      if tx
        "#{Time(tx['date']).strftime("%Y-%m-%d %H:%M:%S")} " +
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
end
