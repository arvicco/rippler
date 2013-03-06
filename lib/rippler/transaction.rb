
module Rippler
  class Transaction
    def initialize data # data hash
      @data = data
    end

    def name account
      Rippler::Addresses[account] || account
    end

    def amount money
      if money.is_a? Hash
         "#{money['value']}/#{money['currency']}/#{name(money['issuer'])}"
      else
        "#{money.to_i/1000000.0}/XRP"
      end

    end

    def to_s
      tx = @data["tx"]
      case tx["TransactionType"]
      when "Payment"
        "PAY #{amount(tx['Amount'])} #{name(tx['Account'])} > #{name(tx['Destination'])}"
      # when "OfferCancel"
      #   "CAN #{name(tx['Account'])} ##{tx['Sequence']}"
      # when "OfferCreate"
      #   "OFR #{name(tx['Account'])} ##{tx['Sequence']} offers " +
      #     "#{amount(tx['TakerGets'])} for #{amount(tx['TakerPays'])}"
      # when "TrustSet"
      #   "TRS #{amount(tx['LimitAmount'])} #{name(tx['Account'])}"
      else
        tx
      end
    end
  end
end
