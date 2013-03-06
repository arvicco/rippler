require 'eventmachine'
require 'faye/websocket'
require "json"
require "rippler/version"
require 'rippler/transaction'
require 'rippler/contacts'

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

  # Make a single JSON request to Ripple over Websockets, return Ripple reply
  def self.request params
    reply = ''

    EM.run {
      ws = Faye::WebSocket::Client.new(RIPPLE_URI)

      ws.onopen = lambda do |event|
        # p [:open]
        ws.send params.to_json
      end

      ws.onmessage = lambda do |event|
        # p [:message]
        reply = JSON.parse(event.data)
        ws.close
      end

      ws.onerror = lambda do |event|
        # p [:error, event]
      end

      ws.onclose = lambda do |event|
        # p [:close, event.code, event.reason]
        ws = nil
        EM.stop
      end
    }
    reply
  end

  # These are user-defined methods that post-process Ripple replies
  def self.my_info params
    request( {command: "account_info", ident: MY_ACCT}.merge(params) )
  end

  def self.my_tx params
    reply = request( {command: "account_tx",
                      account: MY_ACCT,
                      ledger_min: 303000,
                      ledger_max: 329794,
                      resume: 0,
                      sort_asc: 1
                      }.merge(params) ) #(optional)
    txs = reply["result"]["transactions"]
    txs.map {|t| Transaction.new(t).to_s}
  end
end
