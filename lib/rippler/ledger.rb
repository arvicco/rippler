module Rippler
  # Represents a single LedgerClose event
  class Ledger < OpenStruct
    include Rippler::Utils

    def to_s
      "#{Time(self.ledger_time, :unix).strftime("%Y-%m-%d %H:%M:%S")} " +
        "Ledger ##{self.ledger_index}, txn: #{self.txn_count}"
    end
  end
end
