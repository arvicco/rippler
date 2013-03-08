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
  RIPPLE_URI = 'wss://s1.ripple.com:51233'
  MY_ACCT = Rippler::Contacts["arvicco"]

  # Turn command line arguments into command json
  def self.process args
    command_line = args.empty? ? ['account_info'] : args.dup

    command = command_line.shift
    params = Hash[*command_line.map {|p| p.split(':')}.flatten]
    # p command, params

    if Rippler.respond_to? command # pre-defined Rippler method
      Rippler.send command, params
    else # Arbitrary API command
      Rippler.request params.merge(command: command)
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
        yield message
        ws.close unless streaming
      end

      ws.onerror = lambda do |event|
        p [:error, event]
      end

      ws.onclose = lambda do |event|
        # p [:close, event.code, event.reason]
        ws = nil
        EM.stop
      end
    }
  end

  # These are user-defined methods that post-process Ripple replies
  def self.subscribe params
    em_request( true, {command: "subscribe", id: 0, streams: ['transactions', 'ledger' ]}.merge(params)) do |message|

      case message['type']
      when "ledgerClosed"
        ledger = Ledger.new(message)
        puts ledger if ledger.txn_count > 0
      when "transaction"
        pp Transaction.new(message)
      else
        pp message
      end
    end
  end

  # These are user-defined methods that post-process Ripple replies
  def self.my_info params
    request( {command: "account_info", ident: MY_ACCT}.merge(params) )
  end

  def self.history params
    reply = request( {command: "account_tx",
                      account: MY_ACCT,
                      ledger_min: 280000, # 312000,
                      ledger_max: 300000, #329794,
                      resume: 0,
                      sort_asc: 1
                      }.merge(params) ) #(optional)
    if reply["error"]
      reply
    else
      txs = reply["result"]["transactions"]
      txs.reverse.map {|t| Transaction.new(t).to_s}.push("Size: #{txs.size}")
    end
  end
end
