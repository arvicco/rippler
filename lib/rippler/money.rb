module Rippler
  class Money
    include Rippler::Utils

    attr_accessor :value, :currency, :issuer

    # Money comes in in 3 formats:
    # Hash:  {'value' => xx, 'currency' => 'XXX', 'issuer' => 'ZZZZZZZ'}
    # String: 'value/currency(/issuer)'
    # Int in a String: XRP amount in drops (x1,000,000)
    # ? Also, generic currency id without value:
    # ? XRP or USD/bitstamp
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
      @issuer = Account(@issuer) if @issuer
    end

    # Uniform currency rate presentation
    def rate cross
      first, second =
      if self.xrp? || cross.dym?
        [self, cross]
      elsif cross.xrp? || self.btc?
        [cross, self]
      else
        [self, cross]
      end
      r = first.value.to_f/second.value.to_f
      r = r.to_i == r ? r.to_i : r
      "#{r}#{first.currency}/#{second.currency}"
    end

    # Allows methods such as xrp? usd? or btc?
    def method_missing meth, *args
      curr = meth.to_s.upcase.match(/^(...)\?$/)[1]
      if curr
        currency == curr
      else
        super
      end
    end

    def to_s
      if @issuer
        "#{@value}/#{@currency}/#{@issuer.name}"
      else
        "#{@value}/#{@currency}"
      end
    end

    def to_hash
      if @issuer
        {'value' => @value.to_s, 'currency' => @currency, 'issuer' => @issuer.address}
      else
        {'value' => @value.to_s, 'currency' => @currency}
      end
    end
  end
end
