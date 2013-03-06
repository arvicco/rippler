require "rippler/version"
require 'faye/websocket'
require 'eventmachine'
require "json"
require "pp"

module Rippler

  def self.run

    EM.run {
      ws = Faye::WebSocket::Client.new('wss://s1.ripple.com:51233')

      ws.onopen = lambda do |event|
        p :open
        ws.send({"command"=>"account_info","ident"=>"rnZoUopPFXRSVGdeDkgbqdft8SbXfJxKYh"}.to_json)
      end

      ws.onmessage = lambda do |event|
        p :message
        pp JSON.parse(event.data)
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
  end
end
