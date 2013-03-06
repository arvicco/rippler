require 'eventmachine'
require 'faye/websocket'
require "json"
require "pp"
require "rippler/version"
require 'rippler/transaction'
require 'rippler/contacts'

module Rippler
  ACCT = Rippler::Contacts["arvicco"]

  def self.account_info account=ACCT
    pp request( command: "account_info", ident: account )
  end

  def self.account_tx account=ACCT
    reply = request( command: "account_tx",
                     account: account,
                     ledger_min: 303000,
                     ledger_max: 329794,
                     resume: 0,
                     sort_asc: 1 ) #(optional)
    txs = reply["result"]["transactions"]
    pp txs.map {|t| Transaction.new(t).to_s}
  end

  def self.request command
    reply = ''

    EM.run {
      ws = Faye::WebSocket::Client.new('wss://s1.ripple.com:51233')

      ws.onopen = lambda do |event|
        p [:open]
        ws.send command.to_json
      end

      ws.onmessage = lambda do |event|
        p [:message]
        reply = JSON.parse(event.data)
        ws.close
      end

      ws.onerror = lambda do |event|
        p [:error, event]
      end

      ws.onclose = lambda do |event|
        p [:close, event.code, event.reason]
        ws = nil
        EM.stop
      end
    }

    reply
  end
end
