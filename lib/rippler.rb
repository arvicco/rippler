require "rippler/version"
require 'faye/websocket'
require 'eventmachine'
require 'rippler/transaction'
require "json"
require "pp"

module Rippler
  ACCT = "rnZoUopPFXRSVGdeDkgbqdft8SbXfJxKYh"

  ACCOUNTS = {
    "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B" =>  'bitstamp',
    "rrpNnNLKrartuEqfJGpqyDwPj1AFPg9vn1" => 'bitstamp_hotwallet',
    "rBcYpuDT1aXNo4jnqczWJTytKGdBGufsre" => 'weex_aud',
    "rpvfJ4mR6QQAeogpXEKnuyGBx8mYCSnYZi" => 'weex_btc',
    "r47RkFi1Ew3LvCNKT6ufw3ZCyj5AJiLHi9" => 'weex_cad',
    "r9vbV3EHvXWjSkeQ6CAcYVPGeq7TuiXY2X" => 'weex_usd',
    "rnZoUopPFXRSVGdeDkgbqdft8SbXfJxKYh" => 'arvicco'
  }

  def self.account_info account=ACCT
    pp request( command: "account_info", ident: account )
  end

  def self.account_tx account=ACCT
    reply = request( command: "account_tx",
                     account: account,
                     ledger_min: 316000,
                     ledger_max: 316794,
                     resume: 0,
                     sort_asc: 1 )#(optional)
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
        p [:message, event]
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
