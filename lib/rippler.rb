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

module Rippler
  extend Rippler::Utils

  RIPPLE_URI = 'wss://s1.ripple.com:51233'
  DEFAULT_ACCT = Rippler::Contacts["molecular"]

  # Turn command line arguments into command json
  def self.process args
    command_line = args.empty? ? ['account_info'] : args.dup

    command = command_line.shift
    params = command_line.map {|p| p.split(':')}.flatten. #         get json pairs
      map {|p| p =~ /\[.*\]/ ? p.gsub(/\[|\]/,'').split(',') : p} # get arrays
    params = Hash[*params]
    params['account'] = Account(params['account']).address if params['account']

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

  # Subscribe needs a streaming wrapper
  def self.subscribe params, &block
    em_request( true, {'command' => "subscribe", 'id' => 0, 'streams' => ['ledger']}.
                merge(params), &(block || lambda {|message| pp message}))
  end

  ### These are user-defined methods that post-process Ripple replies

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

  # Retrieve account transactions history, print out nicely formatted transactions
  def self.history params
    reply = request( {'command' => "account_tx",
                      'account' => DEFAULT_ACCT,
                      'ledger_min' => 0, # 280000, # 312000,
                      'ledger_max' => 500000, #329794,
                      'resume' => 0,
                      'sort_asc' => 1
                      }.merge(params) ) #(optional)
    txs = reply["result"]["transactions"]
    txs.reverse.map {|t| Transaction.new(t).to_s}.push("Total transactions: #{txs.size}")
  end
end
