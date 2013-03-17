module Rippler
  class Account
    include Rippler::Utils

    attr_accessor :address, :balance, :flags

    # String: "evoorhees" or "rpfxDFsjDNtzSBCALKuWoWMkpRp4vxvgrG"
    # Hash:
    # {"Account"=>"rUvpjNBcnt4DLKEVA2XyvJi1YGCfp2EPtk",
    #  "Balance"=>"199999990",
    #  "Flags"=>0,
    #  "LedgerEntryType"=>"AccountRoot",
    #  "OwnerCount"=>0,
    #  "PreviousTxnID"=>"14DBB4EBF6BE71439CE776446337A7E789EB4205D55F1731622DD225AF950BE2",
    #  "PreviousTxnLgrSeq"=>338219,
    #  "Sequence"=>2,
    #  "index"=>"71EE27781DE11E4D3E44052E1264C9F5E01F3F2BC0F5D9A890099914C5031C91"}
    def initialize data
      case data
      when String
        @address = Rippler::Contacts[data] || data
        @name = Rippler::Addresses[@address]
      when Hash
        @address = data["Account"]
        @name = Rippler::Addresses[@address]
        @balance = Money(data["Balance"])
        @flags = data["Flags"]
      end
    end

    def name
      if @name && @name =~ /^X\.\d+/
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
