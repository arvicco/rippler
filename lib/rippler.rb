require 'eventmachine'
require 'faye/websocket'
require "json"
require 'ostruct'

require "rippler/version"
require 'rippler/contacts'
require 'rippler/utils'
require 'rippler/money'
require 'rippler/account'
require 'rippler/ledger'
require 'rippler/transaction'
require 'rippler/line'
require 'rippler/offer'

module Rippler
  extend Rippler::Utils

  RIPPLE_URI = 'wss://s1.ripple.com:51233'
  DEFAULT_ACCT = Rippler::Contacts["molecular"]

  def self.parse_params command_line
    params = command_line.map {|p| p.split(':',2)}.flatten.        # get json pairs
      map {|p| p =~ /\[.*\]/ ? p.gsub(/\[|\]/,'').split(',') : p}. # get arrays
      map {|p| p =~ /\{(.*)\}/ ? self.parse_params($1.split(/\s*,\s*/)) : p} # get objects
    Hash[*params]
  end

  # Turn command line arguments into command json
  def self.process args
    command_line = args.empty? ? ['account_info'] : args.dup

    command = command_line.shift
    params = self.parse_params command_line

    params['account'] = Account(params['account']).address if params['account']
    params['destination_account'] = Account(params['destination_account']).address if params['destination_account']
    params['source_account'] = Account(params['source_account']).address if params['source_account']

    # p command, params

    if respond_to? command # pre-defined Rippler method
      send command, params
    else # Arbitrary API command
      request params.merge('command' => command)
    end
  end

  # Send a single JSON request to Ripple over Websockets, return a single Ripple reply.
  def self.request params, &block
    reply = ''
    em_request false, params, &(block || lambda {|message| reply = message})
    reply
  end

  # Send JSON request to Ripple, yields all json-parsed Ripple messages to a given block.
  def self.em_request streaming=false, params, &block
    EM.run {
      ws = Faye::WebSocket::Client.new(RIPPLE_URI)

      ws.onopen = lambda do |event|
        # p [:open]
        ws.send params.to_json
      end

      ws.onmessage = lambda do |event|
        # p [:message]
        message = JSON.parse(event.data)
        check_error message
        yield message
        ws.close unless streaming
      end

      ws.onerror = lambda do |event|
        # p [:error, event]
        pp event["error"]
        raise "Websocket error"
      end

      ws.onclose = lambda do |event|
        # p [:close, event.code, event.reason]
        ws = nil
        EM.stop
      end
    }
  end

  def self.check_error message
    if message["error"]
      pp message
      raise "Ripple error message"
    end
  end

  ### These API commands need some pre/post-process wrappers

  # book_offers should accept "taker_gets" & "taker_pays" params
  # in both "CUR/issuer" and {"currency":currency, "issuer":address} formats
  def self.book_offers params
    request( params.merge('command' => "book_offers",
                          'taker_gets' => Money(params['taker_gets']).to_hash,
                          'taker_pays' => Money(params['taker_pays']).to_hash))
  end


  # Subscribe needs a streaming wrapper
  def self.subscribe params, &block
    em_request( true, {'command' => "subscribe", 'id' => 0, 'streams' => ['ledger']}.
                merge(params), &(block || lambda {|message| pp message}))
  end

  ### These are user-defined methods that post-process Ripple replies

  # Subscibe to event streams, print events out nicely formatted
  def self.order_book params

    buy = params['buy']
    sell = params['sell']
    reply = book_offers('taker_gets' => buy,'taker_pays' => sell)

    asks = reply['result']['offers'].map {|o| Offer.new(o)}

    reply = book_offers('taker_gets' => sell,'taker_pays' => buy)

    bids  = reply['result']['offers'].map {|o| Offer.new(o)}

    (asks.reverse + bids.unshift("-"*40) ).map(&:to_s)
  end

  # Subscibe to event streams, print events out nicely formatted
  def self.monitor params
    subscribe(params) do |message|
      case message['type']
      when "response"
        puts "#{Ledger.new(message['result'])} starting..."
      when "ledgerClosed"
        ledger = Ledger.new(message)
        puts "#{ledger} active" if ledger.txn_count > 0
      when "transaction"
        pp Transaction.new(message)
      else
        pp message
      end
    end
  end

  # Retrieve non-trivial balances (IOUs and XRP) for a given Ripple account
  def self.balances params
    # Request IOU trust lines and balances
    reply = request( {'command' => "account_lines",
                      'account' => DEFAULT_ACCT,
                      }.merge(params) )
    lines = reply["result"]["lines"]

    # Request account info (with XRP balance)
    reply = request( {'command' => "account_info",
                      'account' => DEFAULT_ACCT,
                      }.merge(params) )
    xrp_balance = Account(reply["result"]["account_data"]).balance

    lines.map do |line|
      line = Line.new(line)
      line.to_s if line.balance.to_f.abs > 0.00001
    end.compact.push("XRP balance: #{xrp_balance}")
  end

  # Retrieve account transactions history, print out nicely formatted transactions
  def self.history params
    reply = request( {'command' => "account_tx",
                      'account' => DEFAULT_ACCT,
                      'ledger_min' => 0, # 280000, # 312000,
                      # 'ledger_max' => 500000, #329794,
                      'resume' => 0,
                      'sort_asc' => 1
                      }.merge(params) ) #(optional)
    txs = reply["result"]["transactions"]
    txs.map {|t| Transaction.new(t)}.map(&:to_s).reverse
    .push("Total transactions: #{txs.size}")
  end

  def self.path_find params
    params.merge!('command' => 'ripple_path_find')
    if params['destination_amount'] && ! params['destination_amount']['issuer']
      params['destination_amount']['issuer'] = params['destination_account']
    end
    reply = request(params)
    reply['result']['alternatives'].map {|alt|
      if alt['source_amount'].is_a?(String)
        # XRP as per https://ripple.com/wiki/JSON_API#XRP
        if alt['source_amount'] =~ /\./
          alt['source_amount'].to_f
        else
          alt['source_amount'].to_i.to_f / 1000000
        end
      else
        "#{alt['source_amount']['value']}/#{alt['source_amount']['currency']}/#{alt['source_amount']['issuer']}"
      end
    }
  end
end
