module Rippler
  class Money
    include Rippler::Utils

    attr_accessor :value, :currency, :issuer

    # Money comes in in 3 formats:
    # Hash:  {'value' => xx, 'currency' => 'XXX', 'issuer' => 'ZZZZZZZ'}
    # String: 'value/currency(/issuer)'
    # Int in a String: XRP amount in drops (x1,000,000)
    def initialize data
      case data
      when Hash
        @value = data['value'].to_f
        @currency = data['currency']
        @issuer = data['issuer']
      when String
        @value, @currency, @issuer = *data.split('/')
        if @currency
          @value = @value.to_f
        else
          @value = @value.to_i/1000000.0
          @currency = "XRP"
        end
      when Int
        @value = data.to_i/1000000.0
        @currency = "XRP"
      end

      @value = @value.to_i if @value.to_i == @value
    end

    def to_s
      if @issuer
        "#{@value}/#{@currency}/#{Account(@issuer)}"
      else
        "#{@value}/#{@currency}"
      end
    end

    def to_hash
      {'value' => @value.to_s, 'currency' => @currency, 'issuer' => @issuer}
    end
  end
end
