module Rippler
  class Account
    include Rippler::Utils

    attr_accessor :address

    # String: "evoorhees" or "rpfxDFsjDNtzSBCALKuWoWMkpRp4vxvgrG"
    def initialize name_or_address
      @address = Rippler::Contacts[name_or_address] || name_or_address
      @name = Rippler::Addresses[@address]
    end

    def name
      if @name && @name =~ /X\.\d*/
        "X.#{@address}"
      else
        @name
      end
    end

    def to_s
      name || address
    end
  end
end
