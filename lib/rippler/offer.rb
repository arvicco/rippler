module Rippler
  class Offer
    include Rippler::Utils

    # attr_accessor :address, :balance, :flags

    # Hash:
    # {"Account"=>"rngJ9Co6MPZxJcyepRv2hMPV1HqaeGCdVU",
    #   "BookDirectory"=> "4627DFFCFF8B5A265EDBD8AE8C14A52325DBFEDAF4F5C32E5E03DACD3F94D000",
    #   "BookNode"=>"0000000000000000",
    #   "Flags"=>0,
    #   "LedgerEntryType"=>"Offer",
    #   "OwnerNode"=>"0000000000000000",
    #   "PreviousTxnID"=> "704A6FCC2DD0AEE9B5F420C3641FB86FFE73F4D233E4B9F6A10E5DE79F7DAACF",
    #   "PreviousTxnLgrSeq"=>432517,
    #   "Sequence"=>191,
    # "TakerGets"=>
    #   {"currency"=>"USD", "issuer"=>"rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B", "value"=>"150"},
    #  "TakerPays"=>"449850000000",
    #  "index"=> "D34C841609A12DAF9DF1B59CA7CB930091A1A16C4A400D8AFDF73311CBB2A2C5",
    #  "taker_gets_funded"=>
    #   {"currency"=>"USD", "issuer"=>"rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B", "value"=>"51.73532238374231"},
    #  "taker_pays_funded"=>"155154231828"},
    def initialize data, only_show_funded
      @data = data
      @only_show_funded = only_show_funded
      @take
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

    def gets
      @get ||= Money(@data['TakerGets'])
    end

    def pays
      @pay = Money(@data['TakerPays'])
    end

    def funded_gets
      if @data['taker_gets_funded']
        @funded_get ||= Money(@data['taker_gets_funded'])
      else
        @funded_get ||= gets
      end
    end

    def funded_pays
      if @data['taker_pays_funded']
        @funded_pay = Money(@data['taker_pays_funded'])
      else
        @funded_pay = pays
      end
    end

    def account
      @account ||= Account(@data['Account'])
    end

    def funded
      if @data['taker_gets_funded'] || @data['taker_pays_funded']
        funds = Money(@data['taker_gets_funded'])
        " (#{(funds.value/gets.value*100).round(4)}% funded)"
      end
    end

    def to_s
      if @only_show_funded == "true"
        "OFR at #{gets.rate(pays)}, #{funded_gets.value.round(4)} for " +
        "#{funded_pays.value.round(4)} by #{account} ##{@data['Sequence']}"
      else
        "OFR at #{gets.rate(pays)}, #{gets.value.round(4)} for " +
        "#{pays.value.round(4)}#{funded} by #{account} ##{@data['Sequence']}"
      end
    end
  end
end
